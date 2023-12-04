# frozen_string_literal: true

##
# The {MarkdownQuestionBehavior} mixin module is for extracting
#
# @note Consider that the column `SECTION_` may not be the best named.  We might want `TITLE` and
#       `TEXT_`; however this format helps us stay closer to the other question types.
module MarkdownQuestionBehavior
  extend ActiveSupport::Concern

  included do
    serialize :data, JSON
    validates :data, presence: true
  end

  class ImportCsvRow < Question::ImportCsvRow
    def extract_answers_and_data_from(row)
      @section_integers = []

      row.headers.each do |header|
        next unless header.upcase.start_with?("SECTION_")
        @section_integers << Integer(header.sub("SECTION_", ""))
      end

      @section_integers.sort!

      markdown = @section_integers.each_with_object([]) do |integer, acc|
        acc << row.fetch("SECTION_#{integer}")
      end.join("\n")

      # TODO: When should we convert this to HTML?  I assume Markdown is inadequate?  We can defer
      # on this decision until approval of the data transport format.
      @data = { "markdown" => markdown }
    end

    def validate_well_formed_row
      errors.add(:base, "expected one or more SECTION_ columns") unless @section_integers.any?
    end
  end
end
