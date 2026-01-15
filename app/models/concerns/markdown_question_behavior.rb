# frozen_string_literal: true

##
# The {MarkdownQuestionBehavior} mixin module is for extracting
#
# @note Consider that the column `TEXT_` may not be the best named.  We might want `TITLE` and
#       `TEXT_`; however this format helps us stay closer to the other question types.
module MarkdownQuestionBehavior
  extend ActiveSupport::Concern

  included do
    serialize :data, JSON
    validates :data, presence: true
  end

  DATA_KEY_NAME = 'html'
  TEXT_KEY_NAME = 'text'

  class ImportCsvRow < Question::ImportCsvRow
    # rubocop:disable Metrics/MethodLength

    ##
    # This method will set the @text and @data for import.  Most notably we're assuming that the
    # input is multiple columns of Markdown.  It will also strip the provided text fields of any
    # HTML, then convert that text to markdown.
    #
    # @param row [CsvRow, Hash]
    #
    # @see https://api.rubyonrails.org/classes/ActionView/Helpers/SanitizeHelper.html#method-i-strip_tags SanitizeHelper.strip_tags
    def extract_answers_and_data_from(row)
      @section_integers = []

      row.headers.each do |header|
        next unless header.upcase.start_with?("TEXT_")
        @section_integers << Integer(header.sub("TEXT_", ""))
      end

      @section_integers.sort!
      rows = []
      @text = row.fetch('TEXT')

      # Why the double carriage return?  Without that if we have "Text\n* Bullet" that will be
      # converted to "<p>Text\n* Bullet</p>" But with the "\n\n" we end up with
      # "<p>Text</p><ul><li>Bullet</li></ul>"; and multiple bullets also work.
      @html = @section_integers.each_with_object(rows) do |integer, acc|
        acc << row.fetch("TEXT_#{integer}")
      end.join("\n\n")

      # We need to ensure that we're not letting stray HTML make it's way into the application;
      # without stripping tags this is a vector for Javascript injection.
      @html = ApplicationController.helpers.sanitize(@html)
      @text = ApplicationController.helpers.sanitize(@text)

      # We're stripping the new line characters as those are not technically not-needed for storage
      # nor transport.
      html = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(@html).delete("\n")

      @data = { DATA_KEY_NAME => html, TEXT_KEY_NAME => @text }
    end
    # rubocop:enable Metrics/MethodLength

    def validate_well_formed_row
      errors.add(:base, "expected one or more TEXT columns") unless row.key?("TEXT") || @section_integers.any?
    end
  end

  ##
  # @return [NilClass] when we have not yet set the data.
  # @return [String] HTML unsafe content (e.g. raw HTML that has not been verified as safe nor
  #         escaped.)
  # @raise [KeyError] when the data does not have an 'html' key.  This is indicative of a disconnect
  #        in the mapping of the imported data to the serialized form.
  def html
    data&.fetch(DATA_KEY_NAME)
  end
end
