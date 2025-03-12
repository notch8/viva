# frozen_string_literal: true

module QuestionFormatter
  # rubocop:disable Metrics/ClassLength
  class MoodleService < BaseService
    self.output_format = 'xml'
    self.format = 'moodle' # used as format parameter
    self.file_type = 'text/xml'

    attr_accessor :xml

    def format_content
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        @xml = xml
        xml.quiz do
          questions.each do |question|
            next if question.moodle_export_type.nil?
            @question = question
            format_by_type
          end
        end
      end

      builder.to_xml
    end

    private

    def essay_type
      name_text = question.text
      questiontext_text = question.data['html']

      question_wrapper(name_text:, questiontext_text:)
    end

    def matching_type
      question_wrapper do
        feedback_tags
        question.data.each do |d|
          xml.subquestion(format: 'html') do
            text_cdata_wrapper("<p>#{d['answer']}</p>")
            xml.answer do
              xml.text_ d['correct'].first
            end
          end
        end
      end
    end

    def traditional_type
      question_wrapper do
        feedback_tags
        data = question.data
        total_fraction = (100.0 / data.count { |d| d['correct'] }).round(5)
        total_fraction = total_fraction == 100.0 ? total_fraction.to_i : total_fraction
        data.each do |d|
          fraction = d['correct'] ? total_fraction : 0
          xml.single_ total_fraction == 100 ? true : false
          xml.answer(fraction:) do
            text_cdata_wrapper("<p>#{d['answer']}</p>")
          end
        end
      end
    end

    def question_wrapper(name_text: "#{question.class} #{question.id}", questiontext_text: "<p>#{question.text}</p>")
      xml.question(type: question.moodle_export_type) do
        xml.tags do
          question.subjects.each do |subject|
            xml.tag do
              xml.text_ subject.name
            end
          end
        end

        xml.name do
          # populates <quiz><question><name><text> field
          xml.text_ name_text
        end

        questiontext_wrapper(questiontext_text:)

        yield if block_given?
      end
    end

    def questiontext_wrapper(questiontext_text:)
      xml.questiontext(format: 'html') do
        add_image_files
        text_cdata_wrapper(image_tags.join + questiontext_text)
      end
    end

    def add_image_files
      question.images.each do |image|
        xml.file(name: image.original_filename, path: '/', encoding: 'base64') do
          xml << image.base64_encoded_data
        end
      end
    end

    def image_tags
      question.images.map do |image|
        "<p><img src=\"@@PLUGINFILE@@/#{image.original_filename}\" alt=\"#{image.alt_text}\"></p>"
      end
    end

    def text_cdata_wrapper(text)
      xml.text_ do
        xml.cdata(text)
      end
    end

    def feedback_tags
      xml.correctfeedback(format: 'html') do
        text_cdata_wrapper('<p>Your answer is correct.</p>')
      end
      xml.partiallycorrectfeedback(format: 'html') do
        text_cdata_wrapper('<p>Your answer is partially correct.</p>')
      end
      xml.incorrectfeedback(format: 'html') do
        text_cdata_wrapper('<p>Your answer is incorrect.</p>')
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
