# frozen_string_literal: true

##
# The "Select All That Apply" question has one or more possible correct answers.
class Question::SelectAllThatApply < Question
  self.type_name = "Select All That Apply"

  def self.build_row(row)
    text = row['TEXT']
    category_names = extract_category_names_from(row)
    keyword_names = extract_keyword_names_from(row)

    answers = row['ANSWERS']&.split(',')&.map(&:to_i)
    answer_columns = row.headers.select { |header| header.present? && header.start_with?("ANSWER_") }
    data = answer_columns.map do |col|
      index = col.split(/_+/).last.to_i
      { answer: row[col], correct: answers.include?(index) }
    end

    new(text:, data:, category_names:, keyword_names:)
  end

  # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
  # for the data to be used in the application, beyond export of data, is minimal.
  serialize :data, JSON
  validate :well_formed_serialized_data
  validates :data, presence: true

  ##
  # Verify that the resulting data attribute is an array with each element being an array of a
  # string and boolean.
  #
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Layout/LineLength
  # rubocop:disable Metrics/MethodLength
  def well_formed_serialized_data
    unless data.is_a?(Array)
      errors.add(:data, "expected to be an array, got #{data.class.inspect}")
      return false
    end

    unless data.all? do |pair|
      pair.is_a?(Hash) &&
      pair.keys.sort == ["answer", "correct"] &&
      pair['answer'].present? && pair['answer'].is_a?(String) &&
      pair['answer'].present? && (pair['correct'].is_a?(TrueClass) || pair['correct'].is_a?(FalseClass))
    end
      errors.add(:data, "expected to be an array of arrays, each sub-array having two elements, both of which are strings")
      return false
    end

    # The shape of the data is correct now validate exact number of correct answers.
    correct_answers = data.select { |pair| pair['correct'] == true }

    if correct_answers.count.zero?
      errors.add(:data, "expected one correct answer, but no correct answers were specified.")
      return false
    end

    true
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Layout/LineLength
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
end
