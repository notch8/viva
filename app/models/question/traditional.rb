
# frozen_string_literal: true

##
# One question, many candidate answers, but only one is correct.
class Question::Traditional < Question
  self.type_name = "Traditional"

  ##
  # Represents the mapping process of a CSV Row to the underlying {Question::Traditional}.
  class CsvRow
    attr_reader :question, :row, :question_type

    delegate :save!, :valid?, :persisted?, :keywords, :level, :data, :save, :reload, :errors, to: :question
    attr_reader :text, :level, :subject_names, :keyword_names, :answers, :answer_columns

    def initialize(row:, question_type:)
      @row = row
      @question_type = question_type

      @text = row['TEXT']
      @level = row['LEVEL']
      @subject_names = Question.extract_subject_names_from(row)
      @keyword_names = Question.extract_keyword_names_from(row)
      @answers = row['ANSWERS']&.split(/\s*,\s*/)&.map(&:to_i)
      @answer_columns = row.headers.select { |header| header.present? && header.start_with?("ANSWER_") }
    end

    def question
      return @question if defined?(@question)

      data = answer_columns.each_with_object([]) do |col, array|
        index = col.split(/_+/).last.to_i
        next if row[col].blank? && !answers.include?(index)
        array << { answer: row[col], correct: answers.include?(index) }
      end
      @question = question_type.new(text:, data:, subject_names:, keyword_names:, level:)
    end
  end

  def self.build_row(row)
    CsvRow.new(question_type: self, row: row)
  end

  # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
  # for the data to be used in the application, beyond export of data, is minimal.
  #
  # Because we coerce the data to JSON, the keys come back stringified.
  serialize :data, JSON
  validate :well_formed_serialized_data
  validates :data, presence: true

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
      errors.add(:data, "expected to be a Array, got #{data.class.inspect}")
      return false
    end

    unless data.all? { |pair| pair.is_a?(Hash) && pair.keys.sort == ['answer', 'correct'] && pair['answer'].is_a?(String) && (pair['correct'].is_a?(TrueClass) || pair['correct'].is_a?(FalseClass)) }
      errors.add(:data, "expected to be an array of hashes, each hash an answer and correct element, the answer being a string and the correct being a boolean")
      return false
    end

    # The shape of the data is correct now validate exact number of correct answers.
    correct_answers = data.select { |pair| pair['correct'] == true }

    if correct_answers.count.zero?
      errors.add(:data, "expected one correct answer, but no correct answers were specified.")
      return false
    elsif correct_answers.count > 1
      errors.add(:data, "expected only one correct answer, but instead have #{correct_answers.count} correct answers.")
      return false
    end

    true
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
end
