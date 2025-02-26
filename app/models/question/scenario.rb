# frozen_string_literal: true

##
# A {Question::Scenario} is a part of a {Question::StimulusCaseStudy}; it introduces the questions
# that follow.  It does not have answers but is instead interweaved with the other
# {Question::StimulusCaseStudy.child_questions}.
class Question::Scenario < Question
  self.type_label = "Scenario"
  self.type_name = "Scenario"
  self.model_exporter = 'scenario'
  self.included_in_filterable_type = false

  class ImportCsvRow < Question::ImportCsvRow
    def extract_answers_and_data_from(_row)
      true
    end

    def validate_well_formed_row
      errors.add(:base, "expected PART_OF column for CSV row.") unless row['PART_OF']
    end
  end

  validate :must_have_a_parent_question

  def must_have_a_parent_question
    errors.add(:base, "must have an associated parent question") if parent_question.blank?
  end
  private :must_have_a_parent_question

  after_initialize :coerce_attributes_to_expected_state
  before_save :coerce_attributes_to_expected_state

  def coerce_attributes_to_expected_state
    self.data = nil
    self.child_of_aggregation = true
  end
  private :coerce_attributes_to_expected_state
end
