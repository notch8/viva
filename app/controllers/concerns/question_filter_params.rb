# frozen_string_literal: true

##
# Concern for extracting question filter parameters from request params
# Used by SearchController and BookmarksController to avoid duplication
module QuestionFilterParams
  extend ActiveSupport::Concern

  private

  def question_filter_values
    user_ids = current_user.admin? ? Array.wrap(params[:selected_users]).map(&:to_i) : []
    filter_my_questions = ActiveModel::Type::Boolean.new.cast(params[:filter_my_questions])
    should_filter_my_questions = filter_my_questions && !current_user.admin?

    {
      keywords: params[:selected_keywords],
      subjects: params[:selected_subjects],
      type_name: params[:selected_types],
      levels: params[:selected_levels],
      bookmarked_question_ids: params[:bookmarked_question_ids],
      bookmarked: ActiveModel::Type::Boolean.new.cast(params[:bookmarked]),
      user: current_user,
      filter_my_questions: should_filter_my_questions,
      user_ids:
    }
  end

  def question_filter_my_questions
    ActiveModel::Type::Boolean.new.cast(params[:filter_my_questions])
  end
end
