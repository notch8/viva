# frozen_string_literal: true

##
# A bow tie {Question}'s structure is as follows:
#
#   Left 1 --              -- Right 1
#            \__ Center __/
#            |            \
#   Left N --              -- Right N
#
#   Left Candidates: A, B, C, D
#   Right Candidates: 1, 2, 3, 4
#   Center Candidates: 𝞪, 𝛃, 𝛅, 𝛄
#
# The left and right side can have one or more candidates, and of those candidates one or more
# correct answers.  The center can have one or more candidates and only one correct answer. (see
# https://allnurses.com/next-generation-nclex-what-t738934/ for an example)
#
# @see #well_formed_serialized_data
#
# @example
#
#  question = Question::BowTie.new(
#    text: "Big Question",
#    data: {
#      center: { label: "Center Label", answers: [{ answer: "To Select", correct: true }, { answer: "To Skip", correct: false }] },
#      left: { label: "Left Label", answers: [{ answer: "LCorrect", correct: true }, { answer: "LIncorrect", correct: false }] },
#      right: { label: "Right Label", answers: [{ answer: "RCorrect", correct: true }, { answer: "LIncorrect", correct: false }] }
#    })
#
#   question.valid?
#   => true
class Question::BowTie < Question
  self.type_name = "Bow Tie"

  # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
  # for the data to be used in the application, beyond export of data, is minimal.
  serialize :data, JSON
  validate :well_formed_serialized_data
  validates :data, presence: true

  EXPECTED_DATA_HASH_KEYS = %w[left center right].freeze

  ##
  # Verify that the resulting data attribute is an array with each element being an array of two
  # strings.
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def well_formed_serialized_data
    unless data.is_a?(Hash)
      errors.add(:data, "expected to be a Hash, got a #{data.class}")
      return false
    end

    unless data.keys.map(&:to_s).sort == EXPECTED_DATA_HASH_KEYS.sort
      errors.add(:data, "expected data Hash keys to be #{EXPECTED_DATA_HASH_KEYS.inspect}, got #{data.keys.inspect}")
      return false
    end

    data.keys.each do |key|
      elements = (data[key.to_s] || data[key.to_sym]).with_indifferent_access
      break unless __validate_is_a_hash(key, elements)
      break unless __validate_answers_structure(key, elements['answers'])
      break unless __validate_label_structure(key, elements['label'])

      if key.to_s == "center"
        break unless __validate_one_and_only_one_true_answer(key, elements['answers'])
      else
        break unless __validate_at_least_one_true_answer(key, elements['answers'])
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def __validate_is_a_hash(key, elements)
    if elements.is_a?(Hash)
      return true if elements.key?(:answers) && elements.key?(:label)
      errors.add(:data, "expected #{key} to be a Hash with keys of 'answers' and 'label'")
    else
      errors.add(:data, "expected #{key} to be a Hash, got a #{elements.class}")
      false
    end
  end

  def __validate_answers_structure(key, answers)
    unless answers.is_a?(Array)
      errors.add(:data, "expected #{key} answers to be an Array, got #{answers.class}.")
      return false
    end

    return true if answers.all? do |a|
                     a.is_a?(Hash) && a.keys.sort == ['answer', 'correct'] && a['answer'].is_a?(String) && a['answer'].present? && (a['correct'].is_a?(TrueClass) || a['correct'].is_a?(FalseClass))
                   end
    errors.add(:data, "expected #{key} answers to be an Array of Arrays; the sub-array having the first element being a String and the second being a Boolean.")

    false
  end

  def __validate_one_and_only_one_true_answer(key, answers)
    count = answers.count { |answer| answer['correct'] == true }
    return true if count == 1

    errors.add(:data, "expected #{key}'s answers to have one and only one correct value; got #{count}.")
    false
  end

  def __validate_at_least_one_true_answer(key, answers)
    return true unless answers.none? { |answer| answer['correct'] == true }

    errors.add(:data, "expected #{key}'s answers to have at least one correct value; got none.")
    false
  end

  def __validate_label_structure(key, label)
    return true if label.is_a?(String) && label.present?

    errors.add(:data, "expected #{key}'s label to be a non-blank String")
    false
  end
end
