# frozen_string_literal: true

##
# Some questions (e.g. {Question::StimulusCaseStudy}) are composed of other questions.  This join
# model provides the mechanism for that aggregation.
class QuestionAggregation < ApplicationRecord
  belongs_to :parent_question, polymorphic: true
  belongs_to :child_question, polymorphic: true
end
