# frozen_string_literal: true

##
# A {Question::StimulusCaseStudy} question is an aggregate of other {Question} records.
class Question::StimulusCaseStudy < Question
  self.type_label = "Case Study"
  self.type_name = "Stimulus Case Study"

  has_many :as_parent_question_aggregations,
           class_name: "QuestionAggregation",
           inverse_of: :parent_question,
           dependent: :destroy,
           as: :parent_question
  has_many :child_questions, -> { order(presentation_order: :asc) },
           through: :as_parent_question_aggregations,
           class_name: "Question",
           source_type: "Question"
end
