# frozen_string_literal: true

##
# A matching {Question}'s data includes pairs (e.g. A goes to B, C goes to D).
#
# @see #well_formed_serialized_data
class Question::Matching < Question
  self.type_name = "Matching"

  # rubocop:disable Metrics/MethodLength
  def self.build_row(row)
    text = row['TEXT']
    subject_names = extract_subject_names_from(row)
    keyword_names = extract_keyword_names_from(row)

    # Ensure that we have all of the candidate indices (the left and right side)
    indices = row.headers.each_with_object([]) do |header, array|
      next if header.blank?
      next unless header.start_with?("LEFT_", "RIGHT_")
      array << header.split(/_+/).last.to_i
    end.uniq.sort

    data = indices.each_with_object([]) do |index, array|
      # It is okay that these will possibly be nil; because our downstream validation will catch
      # them.
      answer = row["LEFT_#{index}"]
      correct = row["RIGHT_#{index}"]&.split(/\s*,\s*/)
      next if answer.blank? && correct.blank?
      array << { answer:, correct: }
    end

    new(text:, data:, subject_names:, keyword_names:)
  end
  # rubocop:enable Metrics/MethodLength

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
