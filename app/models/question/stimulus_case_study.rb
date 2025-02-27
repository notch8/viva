# frozen_string_literal: true

##
# A {Question::StimulusCaseStudy} question is an aggregate of other {Question} records.
class Question::StimulusCaseStudy < Question
  self.type_label = "Case Study"
  self.type_name = "Stimulus Case Study"
  self.model_exporter = 'stimulus_type'
  self.has_parts = true

  has_many :as_parent_question_aggregations,
           class_name: "QuestionAggregation",
           inverse_of: :parent_question,
           dependent: :destroy,
           as: :parent_question
  has_many :child_questions, -> { order(presentation_order: :asc) },
           through: :as_parent_question_aggregations,
           class_name: "Question",
           source_type: "Question"

  class ImportCsvRow < Question::ImportCsvRow
    def extract_answers_and_data_from(*); end

    def validate_well_formed_row
      return unless row['PART_OF']

      errors.add(:base, "A #{question.type_name} cannot be part of another question.")
    end
  end

  ##
  # @note Due to the implementation of {Question.filter_as_json} and {Question.filter}, this is not
  #       performant.  That is it will result in potentially many sub-queries.  One solution would
  #       be to move the has_many relations to Question but that would expose those methods to other
  #       question types.
  #
  # @return [Array<Hash<String, Object>>] each element will have "type_label", "type_name", and
  #         "text".  When the child_question has no {#data} it will be omitted (as in a
  #         {Question::Scenario}).  When the child_question's data is present, it will conform to
  #         that question's {#data} structure (often an Array but could be a Hash).
  def data
    child_questions.map do |question|
      hash = {
        "type_label" => question.type_label,
        "type_name" => question.type_name,
        "text" => question.text
      }
      hash["data"] = question.data if question.data.present?
      hash
    end
  end

  private

  def index_searchable_field
    return if child_questions.empty?

    texts = child_questions.map(&:text)
    child_data = child_questions.map do |question|
      question.send(:index_searchable_field)
    end

    combined_text = (texts + child_data).join(' ').squeeze(' ')
    self.searchable = final_scrub(combined_text)
  end
end
