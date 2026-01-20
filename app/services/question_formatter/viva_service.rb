# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module QuestionFormatter
  class VivaService < BaseService
    # Export viva questions in zipped CSV format for reimporting
    self.output_format = 'zip' # used as file suffix
    self.format = 'viva' # used as format parameter
    self.file_type = 'application/zip'
    self.is_file = true

    attr_reader :questions, :question, :subq

    # @input questions [Array<Question>] array of questions to format
    def initialize(questions)
      super
      @questions = questions
      @processed_questions = []
    end

    def format_content
      gather_question_data
      export_file(@processed_questions, collect_headers(@processed_questions))
    end

    private

    def gather_question_data
      @questions.each do |question|
        @question = question
        @subq = false

        # Process the main question
        row_data = process_question(question)
        @processed_questions << row_data if row_data

        # If it's a Stimulus Case Study, recursively process child questions
        process_stimulus_children(question) if question.type == 'Question::StimulusCaseStudy' && question.respond_to?(:child_questions)
      end
    end

    def process_stimulus_children(parent_question)
      parent_import_id = parent_question.id

      parent_question.child_questions.each_with_index do |child_question, index|
        # Process child with subq flag set to true
        child_row_data = process_question(child_question, true)

        next unless child_row_data
        # Add PART_OF reference to link child to parent
        child_row_data["PART_OF"] = parent_import_id
        # Add PRESENTATION_ORDER based on actual order
        child_row_data["PRESENTATION_ORDER"] = index
        @processed_questions << child_row_data
      end
    end

    def format_by_type
      method = @question.class.model_exporter
      send(method)
    end

    def collect_headers(processed_questions)
      processed_questions.flat_map(&:keys).uniq
    end

    # Export the processed questions into a CSV file and zip it with associated images
    def export_file(processed_questions, all_headers)
      csv_content = CSV.generate(headers: true) do |csv|
        csv << all_headers

        processed_questions.each do |question_hash|
          row = all_headers.map { |header| question_hash[header] }
          csv << row
        end
      end.encode('UTF-8')

      csv_filename = 'viva_questions.csv'

      # Collect ALL images from all questions including children
      all_images = collect_all_images

      zip_file_service = ZipFileService.new(all_images, csv_content, csv_filename)
      zip_file_service.generate_zip
    end

    # Common base data for all question types
    # rubocop:disable Metrics/MethodLength
    def build_base_row_data
      row_data = {
        "IMPORT_ID" => question.id,
        "TYPE" => question.type_name,
        "TEXT" => question.text,
        "LEVEL" => question.level
      }

      # Add image columns if an image exists
      if question.images_as_json.present? && question.images_as_json.first
        image_info = question.images_as_json.first
        # Use the original filename from the image attachment
        row_data["IMAGE_PATH"] = if question.images.first
                                   "images/#{question.images.first.original_filename}"
                                 else
                                   extract_filename_from_url(image_info[:url])
                                 end
        row_data["ALT_TEXT"] = image_info[:alt_text]
      end

      row_data
    end
    # rubocop:enable Metrics/MethodLength

    # Common method to add subjects to row data
    def add_subjects_to_row(row_data)
      subjects = question.subject_names
      subjects.each_with_index do |subject, index|
        row_data["SUBJECT_#{index + 1}"] = subject
      end
      row_data
    end

    # Methods for each question type
    def traditional_type
      row_data = build_base_row_data
      row_data["CORRECT_ANSWERS"] = extract_correct_traditional_answers(question.data)
      answers = extract_traditional_answers(question.data)
      answers.each_with_index do |answer, index|
        row_data["ANSWER_#{index + 1}"] = answer
      end
      add_subjects_to_row(row_data)
    end

    def matching_type
      row_data = build_base_row_data
      question.data.each_with_index do |pair, index|
        row_data["LEFT_#{index + 1}"] = pair['answer']
        row_data["RIGHT_#{index + 1}"] = pair['correct']&.first
      end
      add_subjects_to_row(row_data)
    end

    def essay_type
      row_data = build_base_row_data

      # Extract HTML content and split into blocks
      html_content = question.data['html']
      if html_content.present?
        text_blocks = extract_html_blocks(html_content)
        text_blocks.each_with_index do |block, index|
          row_data["TEXT_#{index + 1}"] = block
        end
      end
      add_subjects_to_row(row_data)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def bowtie_type
      row_data = build_base_row_data
      # Process center section
      center_data = question.data['center']
      if center_data
        row_data["CENTER_LABEL"] = center_data['label']
        center_answers = center_data['answers'] || []
        # Add center answers
        center_answers.each_with_index do |answer, index|
          row_data["CENTER_#{index + 1}"] = answer['answer']
        end
        # Extract correct answer indices for center
        row_data["CENTER_CORRECT_ANSWERS"] = extract_correct_indices(center_answers)
      end
      # Process left section
      left_data = question.data['left']
      if left_data
        row_data["LEFT_LABEL"] = left_data['label']
        left_answers = left_data['answers'] || []
        # Add left answers
        left_answers.each_with_index do |answer, index|
          row_data["LEFT_#{index + 1}"] = answer['answer']
        end
        # Extract correct answer indices for left
        row_data["LEFT_CORRECT_ANSWERS"] = extract_correct_indices(left_answers)
      end
      # Process right section
      right_data = question.data['right']
      if right_data
        row_data["RIGHT_LABEL"] = right_data['label']
        right_answers = right_data['answers'] || []
        # Add right answers
        right_answers.each_with_index do |answer, index|
          row_data["RIGHT_#{index + 1}"] = answer['answer']
        end
        # Extract correct answer indices for right
        row_data["RIGHT_CORRECT_ANSWERS"] = extract_correct_indices(right_answers)
      end
      add_subjects_to_row(row_data)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def categorization_type
      row_data = build_base_row_data

      # For categorization, we need to ensure LEFT and RIGHT columns match
      # The importer expects matching pairs of LEFT_N and RIGHT_N
      question.data.each_with_index do |category_data, index|
        col_index = index + 1
        # LEFT columns contain category names
        row_data["LEFT_#{col_index}"] = category_data['answer']
        # RIGHT columns contain comma-separated items
        items = category_data['correct'] || []
        row_data["RIGHT_#{col_index}"] = items.join(', ')
      end

      add_subjects_to_row(row_data)
    end

    def stimulus_type
      row_data = build_base_row_data
      # Stimulus Case Study questions don't have their own data field
      # They serve as containers for child questions
      # The child questions will be exported as separate rows with PART_OF references
      add_subjects_to_row(row_data)
    end

    def scenario_type
      row_data = build_base_row_data
      # Scenario questions are text-only descriptions that appear as children of Stimulus Case Studies
      add_subjects_to_row(row_data)
    end

    ## supporting methods for each question type
    def extract_correct_traditional_answers(data)
      return '' unless data.is_a?(Array)

      correct_indices = []
      data.each_with_index do |answer, index|
        correct_indices << (index + 1) if answer['correct'] == true
      end

      correct_indices.join(',')
    end

    def extract_traditional_answers(data)
      return [] unless data.is_a?(Array)
      data.pluck('answer')
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def extract_html_blocks(html)
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      blocks = []
      doc.children.each do |child|
        next if child.text? && child.text.strip.empty?
        if child.text?
          blocks << child.text
        elsif child.name == 'div'
          child.children.each do |inner_child|
            next if inner_child.text? && inner_child.text.strip.empty?
            blocks << if inner_child.text?
                        inner_child.text
                      else
                        inner_child.to_html
                      end
          end
        else
          blocks << child.to_html
        end
      end
      blocks = [html] if blocks.empty?
      blocks
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    def extract_correct_indices(answers)
      return '' unless answers.is_a?(Array)
      correct_indices = []
      answers.each_with_index do |answer, index|
        correct_indices << (index + 1) if answer['correct'] == true
      end
      correct_indices.join(',')
    end

    def extract_filename_from_url(url)
      # Get the last part of the URL path which should be the filename
      url.split('/').last
    end

    def collect_all_images
      images = []

      @questions.each do |question|
        # Add images from the parent question
        images.concat(question.images)
        # If it's a Stimulus Case Study, also collect images from children
        next unless question.type == 'Question::StimulusCaseStudy' && question.respond_to?(:child_questions)
        question.child_questions.each do |child|
          images.concat(child.images)
        end
      end
      images
    end
  end
end
# rubocop:enable Metrics/ClassLength
