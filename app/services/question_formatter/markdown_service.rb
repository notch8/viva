# frozen_string_literal: true

##
# Service to handle formatting questions into markdown
module QuestionFormatter
  class MarkdownService < BaseService
    self.output_format = 'md'

    private

    def divider_line
      "\n---\n\n"
    end

    def format_scenario(sub_question)
      "**Scenario:** #{sub_question.text}\n\n"
    end

    def format_question_header
      headers = case @subq
                when true
                  "### Subquestion Type: #{question_type}\n**Subquestion:** #{@question.text}\n\n"
                else
                  "## QUESTION TYPE: #{question_type}\n**QUESTION:** #{@question.text}\n\n"
                end
      headers
    end

    def format_essay_content
      plain_text = format_html(@question.data['html'])
      "**Text:** #{plain_text}\n"
    end

    def format_categories(data)
      data.map do |category|
        items = category['correct'].map.with_index { |item, index| "#{index + 1}) #{item}\n" }.join('')
        "**Category:** #{category['answer']}\n#{items}"
      end.join("\n")
    end
  end
end
