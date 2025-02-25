# frozen_string_literal: true

##
# Service to handle formatting questions into plain text

class PlainTextFormatterService < BaseFormatterService
  protected

  def content_divider
    "\n==========\n\n"
  end

  def format_question_header
    return "QUESTION TYPE: #{question_type}\nQUESTION: #{@question.text}\n\n" unless @subq
    "Subquestion Type: #{question_type}\nSubquestion: #{@question.text}\n\n"
  end
end
