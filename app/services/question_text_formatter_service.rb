# frozen_string_literal: true
require 'nokogiri'

##
# Service to handle formatting questions into plain text
# rubocop:disable Metrics/ClassLength
class QuestionTextFormatterService
  def initialize(question)
    @question = question
  end

  def format
    content = format_by_type
    content + "\n**********\n\n"
  end

  # These methods are protected instead of private so they can be called by other instances
  protected

  def essay_type
    format_question_header + format_essay_content
  end

  def traditional_type
    format_question_header + format_answers(@question.data) { |answer, index| format_traditional_answer(answer, index) }
  end

  def matching_type
    format_question_header + format_answers(@question.data) { |answer, index| format_matching_answer(answer, index) }
  end

  def categorization_type
    format_question_header + format_categories(@question.data)
  end

  def bowtie_type
    format_question_header + format_bowtie_sections
  end

  def stimulus_type
    output = @question.child_questions.map { |sub_question| format_sub_question(sub_question) }
    output[-1] = output[-1].chomp if output.any?
    "Question Type: #{question_type}\nQuestion: #{@question.text}\n\n#{output.join('')}"
  end

  def format_sub_question(sub_question)
    case sub_question.type
    when "Question::Scenario"
      "Scenario: #{sub_question.text}\n\n"
    when "Question::Essay", "Question::Upload"
      "#{QuestionTextFormatterService.new(sub_question).essay_type.chomp}\n\n"
    when "Question::Traditional", "Question::SelectAllThatApply", "Question::DragAndDrop"
      "#{QuestionTextFormatterService.new(sub_question).traditional_type}\n"
    when "Question::Matching"
      "#{QuestionTextFormatterService.new(sub_question).matching_type}\n"
    when "Question::Categorization"
      "#{QuestionTextFormatterService.new(sub_question).categorization_type}\n"
    when "Question::BowTie"
      "#{QuestionTextFormatterService.new(sub_question).bowtie_type}\n"
    end
  end

  private

  def format_question_header
    "Question Type: #{question_type}\nQuestion: #{@question.text}\n\n"
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

  def format_bowtie_sections
    sections = ['center', 'left', 'right'].map do |section|
      answers = @question.data[section]['answers'].map.with_index do |answer, index|
        format_traditional_answer(answer, index)
      end.join('')
      "#{section.capitalize}\n#{answers}"
    end
    sections.join("\n")
  end

  def question_type
    type_name = @question.type.slice(10..-1).titleize
    return 'Multiple Choice' if @question.type == 'Question::Traditional'
    type_name
  end

  def format_html(html)
    rich_text = Nokogiri::HTML(html)
    rich_text.css('a').each { |link| link.replace("#{link.text} (#{link['href']})") }
    rich_text.css('p').each { |p| p.replace("#{p.text}\n") }
    rich_text.css('li').each { |li| li.replace("- #{li.text}\n") }
    rich_text.text.strip
  end

  def format_by_type
    case @question.type
    when 'Question::Essay', 'Question::Upload'
      essay_type
    when 'Question::Traditional', 'Question::SelectAllThatApply', 'Question::DragAndDrop'
      traditional_type
    when 'Question::Matching'
      matching_type
    when 'Question::Categorization'
      categorization_type
    when 'Question::BowTie'
      bowtie_type
    when 'Question::StimulusCaseStudy'
      stimulus_type
    end
  end
end
# rubocop:enable Metrics/ClassLength
