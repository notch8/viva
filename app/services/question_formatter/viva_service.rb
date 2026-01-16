# frozen_string_literal: true

module QuestionFormatter
  class VivaService < BaseService
    # Export viva questions in zipped CSV format for reimporting
    self.output_format = 'zip' # used as file suffix
    self.format = 'viva' # used as format parameter
    self.file_type = 'application/zip'
    self.is_file = true

    attr_reader :questions, :question, :max_answers, :max_subjects

    # @input questions [Array<Question>] array of questions to format
    def initialize(questions)
      super
      @questions = questions
    end

    def format_content
      csv_content = CSV.generate(headers: true) do |csv|
        @max_answers = questions.map { |q| q.data&.size || 0 }.max
        @max_subjects = questions.map { |q| q.subjects&.size || 0 }.max
        csv << build_headers

        @questions.each do |question|
          row = process_question(question)
          csv << row
        end
      end.encode('UTF-8')

      csv_filename = 'viva_questions.csv'
      images = questions.flat_map(&:images)

      zip_file_service = ZipFileService.new(images, csv_content, csv_filename)
      zip_file_service.generate_zip
    end

    private

    def build_headers
      headers = ['IMPORT_ID', 'TYPE', 'TEXT', 'CORRECT_ANSWERS', 'LEVEL']
      # Add answer columns
      (1..max_answers).each { |i| headers << "ANSWER_#{i}" }
      # Add subject columns
      (1..max_subjects).each { |i| headers << "SUBJECT_#{i}" }
      headers
    end

    ##
    def traditional_type
      row = []
      row << question.id
      row << question.type_name
      row << question.text
      row << extract_correct_traditional_answers(question.data)
      row << question.level
      answers = extract_traditional_answers(question.data)
      (1..max_answers).each do |i|
        row << (answers[i - 1] || '')
      end
      subjects = question.subject_names
      (1..max_subjects).each do |i|
        row << (subjects[i - 1] || '')
      end
      row
    end

    ## detailed methods for each question type
    def extract_correct_traditional_answers(data)
      return '' unless data.is_a?(Array)

      # Following the model's validation, there should be exactly one correct answer
      # but we'll handle multiple just in case
      correct_indices = []
      data.each_with_index do |answer, index|
        # Match the 1-indexed convention used in ImportCsvRow
        correct_indices << (index + 1) if answer['correct'] == true
      end

      # Return comma-separated list matching the import format
      correct_indices.join(',')
    end

    def extract_traditional_answers(data)
      return [] unless data.is_a?(Array)

      # Extract answer text in order, matching the data structure
      # shown in the model: { "answer" => "text", "correct" => boolean }
      data.map { |answer| answer['answer'] }
    end

    def image_paths
      question.images.map do |image|
        "images/#{image.original_filename}"
      end
    end
  end
end
