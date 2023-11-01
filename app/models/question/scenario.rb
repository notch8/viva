# frozen_string_literal: true

##
# A {Question::Scenario} is a part of a {Question::StimulusCaseStudy}; it introduces the questions
# that follow.  It does not have answers but is instead interweaved with the other
# {Question::StimulusCaseStudy.child_questions}.
class Question::Scenario < Question
  self.type_label = "Scenario"
  self.type_name = "Scenario"
  self.include_in_filterable_type = false

  class ImportCsvRow < Question::ImportCsvRow
    def extract_answers_and_data_from(_row)
      true
    end

    def question
      return @question if defined?(@question)

      parent_question = questions[row['PART_OF']]&.question

      @question = question_type.new(text: row['TEXT'], parent_question:)

      parent_question.child_questions << @question if parent_question

      @question
    end

    def validate_well_formed_row
      if row['PART_OF']
        errors.add(:data, "expected PART_OF value to be an IMPORT_ID of another row in the CSV.") unless questions[row['PART_OF']]
      else
        errors.add(:data, "expected PART_OF column for CSV row.")
      end
    end
  end

  validate :must_have_a_parent_question

  def must_have_a_parent_question
    errors.add(:base, "must have an associated parent question") if parent_question.blank?
  end
  private :must_have_a_parent_question

  before_save :coerce_attributes_to_expected_state
  after_initialize :coerce_attributes_to_expected_state

  def coerce_attributes_to_expected_state
    self.data = nil
    self.child_of_aggregation = true
  end
  private :coerce_attributes_to_expected_state
end
