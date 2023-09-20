# frozen_string_literal: true

##
# A {Question::Scenario} is a part of a {Question::StimulusCaseStudy}; it introduces the questions
# that follow.  It does not have answers but is instead interweaved with the other
# {Question::StimulusCaseStudy.child_questions}.
class Question::Scenario < Question
  self.type_label = "Scenario"
  self.type_name = "Scenario"
  self.include_in_filterable_type = false

  before_save :coerce_attributes_to_expected_state
  after_initialize :coerce_attributes_to_expected_state

  def coerce_attributes_to_expected_state
    self.data = nil
    self.child_of_aggregation = true
  end
  private :coerce_attributes_to_expected_state
end
