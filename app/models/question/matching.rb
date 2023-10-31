# frozen_string_literal: true

##
# A matching {Question}'s data includes pairs (e.g. A goes to B, C goes to D).
#
# @see #well_formed_serialized_data
class Question::Matching < Question
  self.type_name = "Matching"

  ##
  # Represents the mapping process of a CSV Row to the underlying {Question::Matching}.
  #
  # The primary purpose of this class is to convey meaningful error messages for invalid CSV
  # structures.
  #
  # @see {#validate_well_formed_row}
  class ImportCsvRow < Question::ImportCsvRow
    ##
    # @see #validate_well_formed_row
    #
    # rubocop:disable Metrics/MethodLength
    def extract_answers_and_data_from(row)
      # These are reused in #validate_well_formed_row
      @lefts = []
      @rights = []
      # Ensure that we have all of the candidate indices (the left and right side)
      row.headers.each do |header|
        next if header.blank?

        if header.start_with?("LEFT_")
          @lefts << header.split(/_+/).last.to_i
        elsif header.start_with?("RIGHT_")
          @rights << header.split(/_+/).last.to_i
        end
      end

      indices = (@lefts + @rights).uniq.sort

      @data = indices.each_with_object([]) do |index, array|
        # It is okay that these will possibly be nil; because our downstream validation will catch
        # them.
        answer = row["LEFT_#{index}"]
        correct = row["RIGHT_#{index}"]&.split(/\s*,\s*/)
        next if answer.blank? && correct.blank?
        array << { "answer" => answer, "correct" => correct }
      end
    end
    # rubocop:enable Metrics/MethodLength

    def validate_well_formed_row
      return unless @lefts.sort != @rights.sort
      message = "mismatch of LEFT and RIGHT columns."
      left_has = @lefts - @rights
      message += " Have LEFT_#{left_has.join(', LEFT_')} columns without corresponding RIGHT_#{left_has.join(', RIGHT_')} columns." if left_has.any?
      right_has = @rights - @lefts
      message += " Have RIGHT_#{right_has.join(', RIGHT_')} columns without corresponding LEFT_#{right_has.join(', LEFT_')} columns." if right_has.any?
      errors.add(:data, message)
    end
  end

  def self.build_row(row)
    ImportCsvRow.new(question_type: self, row:)
  end

  # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
  # for the data to be used in the application, beyond export of data, is minimal.
  serialize :data, JSON
  validate :well_formed_serialized_data
  validates :data, presence: true

  ##
  # Verify that the resulting data attribute is an array with each element being an array of two
  # strings.
  #
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  def well_formed_serialized_data
    unless data.is_a?(Array)
      errors.add(:data, "expected to be an array, got #{data.class.inspect}")
      return false
    end

    unless data.all? do |pair|
      pair.is_a?(Hash) &&
      pair.keys.sort == ['answer', 'correct'] &&
      pair['answer'].is_a?(String) &&
      pair['answer'].present? &&
      pair['correct'].present? &&
      pair['correct'].is_a?(Array) &&
      pair['correct'].all?(&:present?)
    end
      errors.add(:data, "expected to be an array of hashes, each hash having an answer and correct, both of which are strings")
      return false
    end

    true
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
end
