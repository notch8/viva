# frozen_string_literal: true

module QuestionFormatter
  class BlackboardService < BaseService
    # Even though this is really a TSV under the hood, Blackboard exports out a .txt extension
    self.output_format = 'txt'

    def format_content
      blackboard_type = @question.blackboard_export_type
      return if blackboard_type.blank?
      format_by_type
      [blackboard_type, @text, @answers].join("\t")
    end

    private

    def traditional_type
      @text = @question.text
      @answers = @question.data.map do |data|
        [data['answer'], coherce_answer_mapper[data['correct'].to_s]].join("\t")
      end
    end

    def essay_type
      @text = [@question.text, remove_newlines(@question.data['html'])].join('<br/>')
      @answers = '[Placeholder essay text]'
    end

    def matching_type
      @text = @question.text
      @answers = @question.data.map do |datum|
        [datum['answer'], datum['correct'].first].join("\t")
      end
    end

    def coherce_answer_mapper
      {
        'true' => 'correct',
        'false' => 'incorrect'
      }
    end

    def remove_newlines(text)
      text.delete("\n")
    end
  end
end
