# frozen_string_literal: true

##
# A {Question::Scenario} is a part of a {Question::StimulusCaseStudy}; it introduces the questions
# that follow.  It does not have answers but is instead interweaved with the other
# {Question::StimulusCaseStudy.child_questions}.
class Question::Scenario < Question
  self.type_label = "Scenario"
  self.type_name = "Scenario"
  self.include_in_filterable_type = false

  def self.import_csv_row(row)
    # TODO: This is naive in that it assumes a full blown object.  It's also highlighting that we're
    # likely going to want a Csv Importer class; one that can handle the validation then reporting
    # errors or persisting objects.
    parent_question = row['PART_OF']
    create!(text: row['TEXT'], parent_question: parent_question)
  end

  validate :must_have_a_parent_question

  def must_have_a_parent_question
    # TODO: Consider that we're validating rows of data; and will likely not persist until after we
    # validate all rows.
    errors.add(:base, "must have an associated parent question") unless parent_question.present?
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
