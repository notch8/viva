# frozen_string_literal: true

module QuestionFormatter
  class VivaService < BaseService
    # Export viva questions in zipped CSV format for reimporting
    self.output_format = 'zip' # used as file suffix
    self.format = 'viva' # used as format parameter
    self.file_type = 'application/zip'
    self.is_file = true

    attr_reader :questions, :question

    # @input questions [Array<Question>] array of questions to format
    def initialize(questions)
      super
      @questions = questions
    end

    def format_content
      processed_questions = gather_question_data
      export_file(processed_questions, collect_headers(processed_questions))
    end

    private

    def gather_question_data
      @questions.map do |question|
        @question = question
        process_question(question)
      rescue NotImplementedError => e
        Rails.logger.error("🚧🚧🚧 Exporting question type #{question.type_name} is not yet implemented for #{self.class.name} 🚧🚧🚧")
        nil
      end.compact
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
      images = questions.flat_map(&:images)

      zip_file_service = ZipFileService.new(images, csv_content, csv_filename)
      zip_file_service.generate_zip
    end

    # Common base data for all question types
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
        # Extract just the filename from the URL
        row_data["IMAGE_PATH"] = extract_filename_from_url(image_info[:url])
        row_data["ALT_TEXT"] = image_info[:alt_text]
      end

      row_data
    end

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

      data.map { |answer| answer['answer'] }
    end

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

            if inner_child.text?
              blocks << inner_child.text
            else
              blocks << inner_child.to_html
            end
          end
        else
          blocks << child.to_html
        end
      end

      blocks = [html] if blocks.empty?
      blocks
    end

    def extract_filename_from_url(url)
      # Get the last part of the URL path which should be the filename
      url.split('/').last
    end

    def image_paths
      question.images.map do |image|
        "images/#{image.original_filename}"
      end
    end
  end
end
