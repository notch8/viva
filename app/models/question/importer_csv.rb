# frozen_string_literal: true

require 'csv'
require 'zip'

##
# The {Question::ImporterCsv} is responsible for:
#
# 1. Receiving a CSV and first looping over all records ensuring their validity.
#    a. And when there is one or more invalid records, reporting those invalid records (without
#       persisting any of the records)
#    b. And when all records are valid, persisting those records.
# 2. Negotiating the parent/child relationship of {Question::StimulusCaseStudy} and it's
#    {Question::Scenario} children as well as other children {Question} objects.
# rubocop:disable Metrics/ClassLength
class Question::ImporterCsv
  ##
  # @todo Maybe we don't want to read the given CSV and pass the text into the object.  However,
  #       that is a later concern refactor that should be relatively easy given these various
  #       inflection points.
  def self.from_file(file, user_id:)
    case File.extname(file)
    when '.csv'
      new(file.read, user_id:)
    when '.zip'
      extracted_files = handle_zip(file)
      csv_file = extracted_files.find { |file| file.ends_with? ".csv" }
      new(File.read(csv_file), extracted_files, user_id:)
    end
  end

  def self.handle_zip(file, destination = Rails.root.join('tmp', 'unzipped', Time.zone.now.strftime("%Y%m%d%H%M%S")))
    extracted_files = []

    ::Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        f_path = File.join(destination, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
        extracted_files << f_path
      end
    end

    extracted_files
  end
  private_class_method :handle_zip

  def initialize(text, extracted_files = [], user_id:)
    @errors = []
    @text = text
    @extracted_files = extracted_files
    @user_id = user_id
  end
  attr_reader :errors, :extracted_files, :user_id

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  def save
    @questions = {}
    @errors = {}
    have_already_verified_headers = false
    # The header_converters ensures that we don't have squirelly little BOM characters and that all
    # columns are titlecase which we later expect.
    # rubocop:disable Metrics/BlockLength
    CSV.parse(@text, headers: true, skip_blanks: true, header_converters: ->(h) { h.to_s.strip.upcase.delete("\xEF\xBB\xBF") }, encoding: 'utf-8') do |row|
      # Guard clause for verifying the provided headers of the CSV.  This is perhaps something to
      # extract.
      unless have_already_verified_headers
        invalid_question = Question.invalid_question_due_to_missing_headers(row:)
        if invalid_question
          @questions[0] = invalid_question
          @errors[:csv] = invalid_question.errors.to_hash
          break # Don't process any more
        else
          have_already_verified_headers = true
        end
      end

      import_id = row['IMPORT_ID'].to_s.strip
      question = Question.build_from_csv_row(row:, questions: @questions, user_id: @user_id)
      if question.valid? && !@questions.key?(import_id)
        attach_images_to_question(question, row['IMAGE_PATH'], row['ALT_TEXT'])
        # If image attachment failed, treat it as an error
        # Check errors on the actual question object, not the wrapper
        actual_question = question.question
        if actual_question.errors.any?
          @errors[:rows] ||= []
          error = actual_question.errors.to_hash.merge(import_id:)
          @errors[:rows] << error
        else
          @questions[import_id] = question
        end
      else
        @errors[:rows] ||= []
        error = question.errors.to_hash.merge(import_id:)
        if @questions.key?(import_id)
          error[:data] ||= []
          error[:data] << "duplicate IMPORT_ID #{import_id} found on multiple rows"
        end
        @errors[:rows] << error
      end
    end
    # rubocop:enable Metrics/BlockLength

    return false if @errors.present?

    Question.transaction do
      @questions.values.all?(&:save!)
    end
  rescue CSV::MalformedCSVError => e
    malformed_csv = Question::GeneralCsvError.new(exception: e)
    @questions[0] = malformed_csv
    @errors[:csv] = malformed_csv.errors.to_hash

    # We have errors, save should return false
    false
  ensure
    cleanup_extracted_files
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def as_json(*args)
    { questions: @questions.values.as_json(*args), errors: @errors.as_json(*args) }
  end

  private

  def attach_images_to_question(question, image_paths, alt_texts)
    return if image_paths.blank?

    # Ensure `question` is an instance of `Question`, not `Question::ImportCsvRow`
    question = question.question
    return unless validate_extracted_files(question)

    alt_text_array = alt_texts.present? ? alt_texts.split(';') : []
    image_paths.split(';').each_with_index do |image_path, index|
      process_image_path(question, image_path, alt_text_array[index])
    end
  end

  def validate_extracted_files(question)
    return true unless extracted_files.empty?

    question.errors.add(:base, "Images specified in CSV but no ZIP file uploaded. Please upload a ZIP file containing both the CSV and image files.")
    false
  end

  def process_image_path(question, image_path, alt_text)
    image_path_stripped = image_path.strip
    return if image_path_stripped.blank?

    found_file = find_image_file(image_path_stripped)
    unless found_file
      add_image_not_found_error(question, image_path_stripped)
      return
    end

    attach_single_image(question, found_file, alt_text)
  end

  def find_image_file(image_path)
    extracted_files.find do |file|
      file.ends_with?("/#{image_path}") ||
        File.basename(file) == image_path ||
        file.ends_with?("\\#{image_path}") # Windows path separator
    end
  end

  def add_image_not_found_error(question, image_path)
    available_files = available_file_names.join(', ')
    question.errors.add(:base, "Image file not found in ZIP: #{image_path}. Available files: #{available_files}")
  end

  def available_file_names
    extracted_files.reject { |f| f.include?('__MACOSX') || f.include?('.DS_Store') }
                   .map { |f| File.basename(f) }
  end

  def attach_single_image(question, file_path, alt_text)
    image = question.images.build
    image.file.attach(io: File.open(file_path), filename: File.basename(file_path))
    image.alt_text = alt_text&.strip
    image.save!
  end

  def cleanup_extracted_files
    return if extracted_files.empty?
    FileUtils.rm_rf(File.dirname(extracted_files.first)) # Clean up extracted files
  end
end
# rubocop:enable Metrics/ClassLength
