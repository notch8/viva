# frozen_string_literal: true

module QuestionFormatter
  class BlackboardService < BaseService
    # Even though this is really a TSV under the hood, Blackboard exports out a .txt extension
    self.output_format = 'txt'
    self.format = 'blackboard' # used as format parameter
    self.file_type = 'text/plain'

    private

    def process_question(_question, _subq = false)
      blackboard_type = @question.blackboard_export_type
      return if blackboard_type.blank?
      format_by_type
      [blackboard_type, @text, @answers].join("\t")
    end

    def traditional_type
      @text = question_text
      @answers = @question.data.map do |data|
        [data['answer'], coherce_answer_mapper[data['correct'].to_s]].join("\t")
      end
    end

    def essay_type
      @text = [question_text, remove_newlines(@question.data['html'])].join('<br/>')
      @answers = '[Placeholder essay text]'
    end

    def matching_type
      @text = question_text
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

    def question_text
      image_tag + @question.text
    end

    def image_tag
      @question.images.map do |image|
        "<img src=\"data:#{image.mime_type};base64,#{image.base64_encoded_data}\" alt=\"#{image.alt_text}\"><br/>"
      end.join
    end
  end
end
