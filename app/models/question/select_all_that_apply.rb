# frozen_string_literal: true

##
# The "Select All That Apply" question has one or more possible correct answers.
class Question::SelectAllThatApply < Question
  # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
  # for the data to be used in the application, beyond export of data, is minimal.
  serialize :data, JSON
  validate :well_formed_serialized_data
  validates :data, presence: true

  ##
  # Verify that the resulting data attribute is an array with each element being an array of a
  # string and boolean.
  def well_formed_serialized_data
    unless data.is_a?(Array)
      errors.add(:data, "expected to be an array, got #{data.class.inspect}")
      return false
    end

    # TODO: Should we validate that at least one is true?
    unless data.all? { |pair| pair.is_a?(Array) && pair.size == 2 && pair.all? { |el| el.present? && pair.index(el).zero? ? el.is_a?(String) : (el.is_a?(TrueClass) || el.is_a?(FalseClass)) } }
      errors.add(:data, "expected to be an array of arrays, each sub-array having two elements, both of which are strings")
      return false
    end

    true
  end
end
