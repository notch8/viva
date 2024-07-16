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
class Question::ImporterCsv
  ##
  # @todo Maybe we don't want to read the given CSV and pass the text into the object.  However,
  #       that is a later concern refactor that should be relatively easy given these various
  #       inflection points.
  def self.from_file(file)
    case File.extname(file)
    when '.csv'
      new(file.read)
    when '.zip'
      extracted_files = handle_zip(file)
      csv_file = extracted_files.find { |file| file.ends_with? ".csv" }
      new(File.read(csv_file), extracted_files)
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

  def initialize(text, extracted_files = [])
    @errors = []
    @text = text
    @extracted_files = extracted_files
  end
  attr_reader :errors, :extracted_files

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
      question = Question.build_from_csv_row(row:, questions: @questions)
      if question.valid? && !@questions.key?(import_id)
        attach_images_to_question(question, row['IMAGE_PATH'], row['ALT_TEXT'])
        @questions[import_id] = question
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

    image_paths.split(';').each_with_index do |image_path, index|
      image_path = extracted_files.find { |file| file.ends_with?("/#{image_path}") }
      # Ensure `question` is an instance of `Question`, not `Question::ImportCsvRow`
      question = question.question

      image = question.images.build
      image.file.attach(io: File.open(image_path.strip), filename: File.basename(image_path.strip))
      image.alt_text = alt_texts.split(';')[index].strip if alt_texts.present?
      image.save!
    end
  end
end
