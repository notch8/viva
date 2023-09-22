# frozen_string_literal: true

##
# Some questions (e.g. {Question::StimulusCaseStudy}) are composed of other questions.  This join
# model provides the mechanism for that aggregation.
class QuestionAggregation < ApplicationRecord
  belongs_to :parent_question, polymorphic: true
  belongs_to :child_question, polymorphic: true

  after_initialize :set_default_presentation_order

  ##
  # There's a database constraint on presentation order; namely it cannot be null.  This
  # short-circuits that constraint, which is important because our test factories run as part of the
  # docker build (via db:seed) and those factories are not yet configured to handle the
  # presentation_order.
  def set_default_presentation_order
    self.presentation_order ||= 0
  end
end
