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
  ANSWER_AND_POSITION_REGEXP = %r{\A(?<direction>#{EXPECTED_DATA_HASH_KEYS.map(&:upcase).join('|')})_(?<index>\d+)}

  ##
  # Represents the mapping process of a CSV Row to the underlying {Question::Traditional}.
  #
  # The primary purpose of this class is to convey meaningful error messages for invalid CSV
  # structures.
  #
  # @see {#validate_well_formed_row}
  class ImportCsvRow < Question::ImportCsvRow
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    def extract_answers_and_data_from(row)
      correct_answer_colum_numbers = {}
      @data = {}
      question_type::EXPECTED_DATA_HASH_KEYS.each do |key|
        correct_answer_colum_numbers[key] = row["#{key.upcase}_ANSWERS"]&.split(/\s*,\s*/)&.map(&:to_i) || []
        data[key] = { "label" => row["#{key.upcase}_LABEL"], "answers" => [] }
      end

      row.each do |header, value|
        next if header.blank?
        match = question_type::ANSWER_AND_POSITION_REGEXP.match(header)
        next unless match

        direction = match[:direction].downcase
        index = match[:index].to_i
        correct = correct_answer_colum_numbers[direction].include?(index)
        next if value.blank? && !correct
        data[direction]['answers'] << { "answer" => value, "correct" => correct }
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength

    def validate_well_formed_row
      validate_labels
      validate_answers
      validate_candidates
    end

    def validate_labels
      expected = question_type::EXPECTED_DATA_HASH_KEYS.map { |direction| "#{direction.upcase}_LABEL" }.sort
      given = row.headers.select { |h| h.present? && h.end_with?("_LABEL") }.sort

      return true if (expected & given) == expected

      errors.add(:base, "Expected columns #{expected.join(', ')} but was missing #{(expected - given).join(', ')} columns.")
    end

    def validate_answers
      expected = question_type::EXPECTED_DATA_HASH_KEYS.map { |direction| "#{direction.upcase}_ANSWERS" }.sort
      given = row.headers.select { |h| h.present? && h.end_with?("_ANSWERS") }.sort

      return true if (expected & given) == expected

      errors.add(:base, "Expected columns #{expected.join(', ')} but was missing #{(expected - given).join(', ')} columns.")
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def validate_candidates
      # I need to ensure that each "answer" for each direction exists
      expected_answer_columns = question_type::EXPECTED_DATA_HASH_KEYS.each_with_object({}) do |direction, hash|
        indices = row["#{direction.upcase}_ANSWERS"]&.split(/\s*,\s*/)&.map(&:to_i) || []
        hash[direction] = indices.map { |i| "#{direction.upcase}_#{i}" }
      end

      given_answer_columns = row.headers.each_with_object({}) do |header, hash|
        next if header.blank?
        match = question_type::ANSWER_AND_POSITION_REGEXP.match(header)
        next unless match

        direction = match[:direction].downcase
        hash[direction] ||= []
        hash[direction] << "#{direction.upcase}_#{match[:index].to_i}"
      end

      question_type::EXPECTED_DATA_HASH_KEYS.each do |direction|
        expected = expected_answer_columns.fetch(direction, []).sort
        given = given_answer_columns.fetch(direction, []).sort
        next if (expected & given) == expected

        errors.add(:base, "Expected columns #{expected.join(', ')} but was missing #{(expected - given).join(', ')} columns.")
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
  end

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
