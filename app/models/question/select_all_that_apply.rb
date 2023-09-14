# frozen_string_literal: true

##
# The "Select All That Apply" question has one or more possible correct answers.
class Question::SelectAllThatApply < Question
  def self.import_csv_row(row)
    text = row['TEXT']
    answers = row['ANSWERS']&.split(',')&.map(&:to_i)
    answer_columns = row.headers.select { |header| header.present? && header.start_with?("ANSWER_") }
    data = answer_columns.map do |col|
      index = col.split(/_+/).last.to_i
      [row[col], answers.include?(index)]
    end

    create!(text:, data:)
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
  def well_formed_serialized_data
    unless data.is_a?(Array)
      errors.add(:data, "expected to be an array, got #{data.class.inspect}")
      return false
    end

    unless data.all? { |pair| pair.is_a?(Array) && pair.size == 2 && pair.all? { |el| el.present? && pair.index(el).zero? ? el.is_a?(String) : (el.is_a?(TrueClass) || el.is_a?(FalseClass)) } }
      errors.add(:data, "expected to be an array of arrays, each sub-array having two elements, both of which are strings")
      return false
    end

    # The shape of the data is correct now validate exact number of correct answers.
    correct_answers = data.select { |pair| pair.last == true }

    if correct_answers.count.zero?
      errors.add(:data, "expected one correct answer, but no correct answers were specified.")
      return false
    end

    true
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
end
