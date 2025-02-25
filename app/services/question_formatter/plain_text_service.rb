# frozen_string_literal: true

##
# Service to handle formatting questions into plain text
module QuestionFormatter
  class PlainTextService < BaseService
    self.output_format = 'txt'

    private

    def divider_line
      "\n==========\n\n"
    end

    def format_scenario(sub_question)
      "Scenario: #{sub_question.text}\n\n"
    end

    def format_question_header
      return "QUESTION TYPE: #{question_type}\nQUESTION: #{@question.text}\n\n" unless @subq
      "Subquestion Type: #{question_type}\nSubquestion: #{@question.text}\n\n"
    end

    def format_categories(data)
      data.map do |category|
        items = category['correct'].map.with_index { |item, index| "#{index + 1}) #{item}\n" }.join('')
        "Category: #{category['answer']}\n#{items}"
      end.join("\n")
    end
  end
end
