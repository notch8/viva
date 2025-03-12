# frozen_string_literal: true
require 'nokogiri'

# rubocop:disable Metrics/ClassLength
module QuestionFormatter
  class BaseService
    ##
    # Service to handle formatting questions for downloads
    class_attribute :output_format, default: nil
    class_attribute :format, default: nil
    class_attribute :file_type, default: nil
    class_attribute :is_file, default: false

    attr_reader :questions, :subq, :question

    def initialize(questions)
      @questions = questions
    end

    def format_content
      question_content = []
      @questions.each do |question|
        @question = question
        content = process_question(question)
        question_content << content + divider_line if content.present?
      end
      question_content.join(join_by)
    end

    # These methods are protected instead of private so they can be called by other instances
    protected

    def join_by
      "\n\n"
    end

    def process_question(question, subq = false)
      @question = question
      @subq = subq
      format_by_type
    end

    def essay_type
      format_question_header + format_essay_content
    end

    def traditional_type
      format_question_header + format_answers(question.data) { |answer, index| format_traditional_answer(answer, index) }
    end

    def matching_type
      format_question_header + format_answers(question.data) { |answer, index| format_matching_answer(answer, index) }
    end

    def categorization_type
      format_question_header + format_categories(question.data)
    end

    def bowtie_type
      format_question_header + format_bowtie_sections
    end

    def stimulus_type
      header = format_question_header
      output = question.child_questions.map { |sub_question| format_sub_question(sub_question) }

      # remove extra line breaks
      output[-1] = output[-1].chomp if output.any?
      "#{header}#{output.join('')}"
    end

    def format_sub_question(sub_question)
      case sub_question.type
      when "Question::Scenario"
        format_scenario(sub_question)
      else
        "#{process_question(sub_question, true)}\n"
      end
    end

    def format_by_type
      method = question.class.model_exporter
      begin
        send(method)
      rescue
        "Question type: #{question_type} requires a valid export format method"
      end
    end

    private

    def divider_line
      ''
    end

    def format_scenario(question)
      raise NotImplementedError, "Subclasses must implement format_scenario"
    end

    def format_question_header
      raise NotImplementedError, "Subclasses must implement format_question_header"
    end

    def format_essay_content
      plain_text = format_html(question.data['html'])
      "Text: #{plain_text}\n"
    end

    def format_answers(data)
      data.map.with_index { |answer, index| yield(answer, index) }.join('')
    end

    def format_traditional_answer(answer, index)
      "#{index + 1}) #{answer['correct'] ? 'Correct' : 'Incorrect'}: #{answer['answer']}\n"
    end

    def format_matching_answer(answer, index)
      "#{index + 1}) #{answer['answer']}\n   Correct Match: #{answer['correct'].first}\n"
    end

    def format_categories(data)
      raise NotImplementedError, "Subclasses must implement format_categories"
    end

    def format_bowtie_sections
      sections = ['center', 'left', 'right'].map do |section|
        answers = question.data[section]['answers'].map.with_index do |answer, index|
          format_traditional_answer(answer, index)
        end.join('')
        "#{section.capitalize}\n#{answers}"
      end
      sections.join("\n")
    end

    def question_type
      question.class.type_name
    end

    def format_html(html)
      rich_text = Nokogiri::HTML(html)
      rich_text.css('a').each { |link| link.replace("#{link.text} (#{link['href']})") }
      rich_text.css('p').each { |p| p.replace("#{p.text}\n") }
      rich_text.css('li').each { |li| li.replace("- #{li.text}\n") }
      rich_text.text.strip
    end
  end
end
# rubocop:enable Metrics/ClassLength
