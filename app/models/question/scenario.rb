# frozen_string_literal: true

##
# A {Question::Scenario} is a part of a {Question::StimulusCaseStudy}; it introduces the questions
# that follow.  It does not have answers but is instead interweaved with the other
# {Question::StimulusCaseStudy.child_questions}.
class Question::Scenario < Question
  self.type_label = "Scenario"
  self.type_name = "Scenario"
  self.include_in_filterable_type = false

  before_save :always_be_a_child_of_aggregation
  after_initialize :always_be_a_child_of_aggregation

  def always_be_a_child_of_aggregation
    self.child_of_aggregation = true
  end
end
