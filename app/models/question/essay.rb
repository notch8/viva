# frozen_string_literal: true

##
# One question that involves a lengthy introduction to the concept and has a "Rich Text" ask.
class Question::Essay < Question
  self.type_name = "Essay"

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

  serialize :data, JSON
  validates :data, presence: true
end
