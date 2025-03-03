# frozen_string_literal: true

module QuestionFormatter
  class BlackboardService < BaseService
    # Even though this is really a TSV under the hood, Blackboard exports out a .txt extension
    self.output_format = 'txt'

    def format_content
      case @question
      when Question::Traditional, Question::SelectAllThatApply
        traditional_type
      when Question::Essay
        essay_type
      when Question::Matching
        matching_type
      end

      [type_mapper, @text, @answers].join("\t")
    end

    private

    def traditional_type
      @text = @question.text
      @answers = @question.data.map do |data|
        [data['answer'], coherce_answer_mapper[data['correct'].to_s]].join("\t")
      end
    end

    def essay_type
      @text = [@question.text, @question.data['html']].join('<br/>')
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

    def type_mapper
      case @question
      when Question::Traditional
        'MC'
      when Question::SelectAllThatApply
        'MA'
      when Question::Essay
        'ESS'
      when Question::Matching
        'MAT'
      end
    end
  end
end
