# frozen_string_literal: true

##
# There are conceptually two drag and drop flavors:
#
# 1. Pick the ones that are correct (similar to {Question::SelectAllThatApply}).
# 2. Place the answers in the correct slots.
#
# The specs provide what should be extensive coverage of the use cases.
#
# @example
#   # A slot based drag-n-drop
#   question = Question::DragAndDrop.new(
#                text: "The color ___1___ is comprised of ___2___ and ___2___."
#                data: [{ answer: "Green", correct: 1 }, { answer: "Blue", correct: 2 }, { answer: "Yellow", correct:2 }, { answer: "Red", correct: false }])
#
# @example
#   # An all that apply based drag-n-drop
#   question = Question::DragAndDrop.new(
#                text: "The following are animals:"
#                data: [{ answer: "Aardvark", correct: true }, { answer: "Blue", correct: false }, { answer: "Yellow", correct:false }, { answer: "Cat", correct: true }])
class Question::DragAndDrop < Question
  self.type_name = "Drag and Drop"

  ##
  # Represents the mapping process of a CSV Row to the underlying {Question::DragAndDrop}.
  #
  # The primary purpose of this class is to convey meaningful error messages for invalid CSV
  # structures.
  #
  # @see {#validate_well_formed_row}
  class ImportCsvRow < Question::ImportCsvRow
    attr_reader :answers, :answer_columns

    def extract_answers_and_data_from(row)
      # We need to sniff out the type based on the text.
      record = question_type.new(text:, keyword_names:, subject_names:, level:)
      send("extract_#{record.sub_type}", row:, record:)
    end

    def validate_well_formed_row
      # For each of the named slot numbers; there needs to be a corresponding ANSWER_i column
      answers_as_column_names = answers.map { |a| "ANSWER_#{a}" }
      intersect = (answers_as_column_names & answer_columns)

      if intersect != answers_as_column_names
        message = "CORRECT_ANSWERS column indicates that #{answers_as_column_names.join(', ')} " \
                  "columns should be the correct answer, but there's a mismatch with the provided ANSWER_ columns."
        errors.add(:base, message)
      end
      correct_answers = data.select { |pair| pair['correct'] }
      return unless correct_answers.count.zero?
      errors.add(:base, "expected at least one correct answer, but no correct answers were specified.")
      false
    end

    private

    def extract_drag_and_drop_to_slots(row:, record:)
      @answers = record.slot_numbers_from_text
      @answer_columns = row.headers.select { |header| header.present? && header.start_with?("ANSWER_") }
      @data = row.headers.each_with_object([]) do |header, array|
        next if header.blank?
        next unless header.start_with?("ANSWER_")

        slot_number = header.split(/_+/).last.to_i
        next if row[header].blank? && @answers.exclude?(slot_number)
        array << { 'answer' => row[header], 'correct' => (@answers.include?(slot_number) ? slot_number : false) }
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def extract_drag_and_drop_all_that_apply(row:, **)
      @answers = row['CORRECT_ANSWERS']
                 &.split(",")
                 &.map { |answer| answer.strip.to_i } ||
                 []
      @answer_columns = row.headers.select { |header| header.present? && header.start_with?("ANSWER_") }
      @data = row.headers.each_with_object([]) do |header, array|
        next if header.blank?
        next unless header.start_with?("ANSWER_")

        index = header.split(/_+/).last.to_i
        next if row[header].blank? && answers.exclude?(index)
        array << { 'answer' => row[header], 'correct' => answers.include?(index) }
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
  end

  # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
  # for the data to be used in the application, beyond export of data, is minimal.
  serialize :data, JSON
  validate :well_formed_serialized_data
  validates :data, presence: true

  # Why three or more underscores?  One or two underscores could be a Markdown format
  SLOT_NUMBERS_FROM_TEXT_REGEXP = %r{_{3,}\s*(\d+)\s*_{3,}}

  ##
  # @return [Array<Integer>]
  def slot_numbers_from_text
    return [] if text.blank?

    text.to_enum(:scan, SLOT_NUMBERS_FROM_TEXT_REGEXP).map { |match| match.first.to_i }
  end

  SUB_TYPE_SLOTTED = "drag_and_drop_to_slots"
  SUB_TYPE_ATA = "drag_and_drop_all_that_apply"

  ##
  # @return [Symbol] describes
  def sub_type
    return SUB_TYPE_SLOTTED if slot_numbers_from_text.any?

    SUB_TYPE_ATA
  end

  ##
  # Verify that the resulting data attribute is an array with each element being an array of two
  # strings.
  #
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def well_formed_serialized_data
    unless data.is_a?(Array)
      errors.add(:base, "expected to be an array, got #{data.class.inspect}")
      return false
    end

    unless data.all? { |pair| pair.is_a?(Hash) && pair.keys.sort == ['answer', 'correct'] && pair['answer'].is_a?(String) && pair['answer'].present? }
      errors.add(:base, "expected to be an array of hashs, each sub-array having an answer and correct element, the answers being strings")
      return false
    end

    candidates = data.pluck('correct')

    if sub_type == SUB_TYPE_SLOTTED
      if candidates.all? { |candidate| candidate.is_a?(Integer) || candidate.is_a?(FalseClass) }
        answer_slots = candidates.select { |candidate| candidate.is_a?(Integer) }.map(&:to_i)
        text_slots = slot_numbers_from_text

        if answer_slots.sort != text_slots.sort
          errors.add(:base, "mismatch of declared slots in text and answers")
          return false
        end
      else
        errors.add(:base, "expected all answers to either map to a text slot or to be false.  Instead have answers marked as True.")
      end
    end

    if sub_type == SUB_TYPE_ATA && candidates.any? { |candidate| !(candidate.is_a?(TrueClass) || candidate.is_a?(FalseClass)) }
      errors.add(:base, "expected all answer candidates to either be either: 1) all True and/or False, or 2) all Numeric or false.")
      return false
    end

    true
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
end
