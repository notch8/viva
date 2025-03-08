# frozen_string_literal: true

require 'csv'

##
# Service to handle formatting questions into D2L's CSV format
module QuestionFormatter
  class D2lService < BaseService
    self.output_format = 'csv'
    attr_reader :questions

    # @input questions [Array<Question>] array of questions to format
    def initialize(questions)
      super
      @questions = questions
    end

    def format_content
      csv_string = CSV.generate do |csv|
        @questions.each do |question|
          next if question.d2l_export_type.nil?
          @question = question
          # method format_by_type is defined in BaseService
          # calling it will generate all the csv rows for the question type
          format_by_type.each do |row|
            csv << row
          end
        end
      end
      csv_string.encode('UTF-8')
    end

    private

    ## shared methods

    def shared_opening_rows
      csv_rows = []
      begin
        csv_rows << ['NewQuestion', question.d2l_export_type]
        csv_rows << ['ID', question.id]
      end
      csv_rows
    end

    def image_url
      image_url = question.images&.first&.url
      return nil if image_url.blank?
      return image_url if base_url.blank?
      base_url + image_url
    end

    def base_url
      default_url_options = Rails.application.config.action_mailer.default_url_options
      return nil if default_url_options.blank?
      host = default_url_options[:host]
      port = default_url_options[:port]
      return nil if host.blank? || port.blank?
      "http://#{host}:#{port}"
    end

    ## called by format type

    def traditional_type
      csv_rows = []
      csv_rows += shared_opening_rows
      csv_rows << ['QuestionText', question.text]
      csv_rows << ['Image', image_url] if image_url
      csv_rows += format_traditional_options(@question.data)
      csv_rows
    end

    def matching_type
      csv_rows = []
      csv_rows += shared_opening_rows
      csv_rows << ['QuestionText', question.text]
      csv_rows << ['Image', image_url] if image_url
      csv_rows += format_matching_options(@question.data)
      csv_rows
    end

    def essay_type
      csv_rows = []
      csv_rows += shared_opening_rows
      csv_rows << ['Title', question.text]
      csv_rows << ['QuestionText', question.data['html'], 'HTML']
      csv_rows << ['Image', image_url] if image_url
      csv_rows
    end

    ## detailed methods for each question type

    def format_traditional_options(data)
      csv_rows = []
      data.each do |answer|
        answer_text = answer['answer']
        answer_value = answer['correct'] ? '100' : '0'
        csv_rows << ['Option', answer_value, answer_text]
      end
      csv_rows
    end

    def format_matching_options(data)
      choice_rows = []
      match_rows = []

      data.each_with_index do |answer, index|
        sequence_number = index + 1
        term_name = answer['answer']
        definition_name = answer['correct'].first

        choice_rows << ['Choice', sequence_number, term_name]
        match_rows << ['Match', sequence_number, definition_name]
      end

      choice_rows + match_rows
    end
  end
end
