# frozen_string_literal: true

module QuestionFormatter
  class MoodleService < BaseService
    self.output_format = 'xml'
    attr_reader :questions, :question
    attr_accessor :xml

    def initialize(questions)
      @questions = questions
    end

    def format_content
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        @xml = xml
        xml.quiz {
          questions.each do |question|
            @question = question
            format_by_type
          end
        }
      end

      builder.to_xml
    end

    private

    def essay_type
      xml.question(type: question.moodle_type) {
        xml.tags {
          question.subjects.each do |subject|
            xml.tag {
              xml.text_ subject.name
            }
          end
        }
        xml.name {
          xml.text_ question.text
        }
        xml.questiontext(format: 'html') {
          question.images.each do |image|
            xml.file(name: image.original_filename, path: '/', encoding:'base64') {
              xml << binary_base_64(image)
            }
          end
          xml.text_ {
            xml['text_'].cdata(image_tags.join + question.data['html'])
          }
        }
      }
    end

    def image_tags
      question.images.map do |image|
        "<p><img src=\"@@PLUGINFILE@@/#{image.original_filename}\" alt=\"#{image.alt_text}\"></p>"
      end
    end

    def binary_base_64(image)
      Base64.strict_encode64(image.binary_data)
    end
  end
end
