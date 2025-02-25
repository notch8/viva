# frozen_string_literal: true
require 'nokogiri'

##
# Service to handle formatting questions for downloads

class BaseFormatterService
  def initialize(question, subq = false)
    @question = question
    @subq = subq
  end

  def format
    format_by_type + content_divider
  end

  protected

  def content_divider
    raise NotImplementedError, "Subclasses must implement content_divider"
  end

  def format_by_type
    method = @question.class.model_exporter
    send(method)
  end

  def format_question_header
    raise NotImplementedError, "Subclasses must implement format_question_header"
  end

  def essay
    format_question_header + format_essay_content
  end

  def upload
    format_question_header + format_essay_content
  end

  def multiple_choice
    format_question_header + format_answers(@question.data) { |answer, index| format_traditional_answer(answer, index) }
  end

  def select_all_that_apply
    format_question_header + format_answers(@question.data) { |answer, index| format_traditional_answer(answer, index) }
  end

  def drag_and_drop
    format_question_header + format_answers(@question.data) { |answer, index| format_traditional_answer(answer, index) }
  end

  def matching
    format_question_header + format_answers(@question.data) { |answer, index| format_matching_answer(answer, index) }
  end

  def categorization
    format_question_header + format_categories(@question.data)
  end

  def bow_tie
    format_question_header + format_bow_tie_sections
  end

  def stimulus_case_study
    output = @question.child_questions.map { |sub_question| format_sub_question(sub_question) }
    # removes additional line breaks from the sub-questions
    output[-1] = output[-1].chomp if output.any?
    "#{format_question_header}#{output.join('')}"
  end

  def format_sub_question(sub_question)
    if sub_question.type == "Question::Scenario"
      "Scenario: #{sub_question.text}\n\n"
    else
      "#{self.class.new(sub_question, true).format_by_type}\n"
    end
  end

  private

  def question_type
    @question.class.type_name.titleize
  end

  def format_essay_content
    plain_text = format_html(@question.data['html'])
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
    data.map do |category|
      items = category['correct'].map.with_index { |item, index| "#{index + 1}) #{item}\n" }.join('')
      "Category: #{category['answer']}\n#{items}"
    end.join("\n")
  end

  def format_bow_tie_sections
    sections = ['center', 'left', 'right'].map do |section|
      answers = @question.data[section]['answers'].map.with_index do |answer, index|
        format_traditional_answer(answer, index)
      end.join('')
      "#{section.capitalize}\n#{answers}"
    end
    sections.join("\n")
  end

  def format_html(html)
    rich_text = Nokogiri::HTML(html)
    rich_text.css('a').each { |link| link.replace("#{link.text} (#{link['href']})") }
    rich_text.css('p').each { |p| p.replace("#{p.text}\n") }
    rich_text.css('li').each { |li| li.replace("- #{li.text}\n") }
    rich_text.text.strip
  end
end
