# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  include Pagy::Backend

  def index
    render inertia: 'Search', props: shared_props
  end

  private

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def shared_props
    query = Question.filter_query(search: params[:search], filter_my_questions:, **filter_values)

    @pagy, @questions_page = pagy(query)

    serialized_questions = Question.format_questions(@questions_page)

    props = {
      keywords: Keyword.names,
      subjects: Subject.names,
      types: Question.type_names,
      type_names: Question.type_names,
      levels: Level.names,
      selectedKeywords: params[:selected_keywords],
      selectedSubjects: params[:selected_subjects],
      selectedTypes: params[:selected_types],
      selectedLevels: params[:selected_levels],
      filterMyQuestions: filter_my_questions,

      # Pass the formatted page
      filteredQuestions: serialized_questions,

      # Pass the metadata
      pagination: pagy_metadata(@pagy),

      bookmarkedQuestionIds: current_user.bookmarks.pluck(:question_id),
      lms: Question.lms
    }

    # Add user filter props for admins only
    if current_user.admin?
      props[:users] = User.order(:email).pluck(:id, :email).map { |id, email| { id:, email: } }
      props[:selectedUsers] = params[:selected_users]
    end

    props
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def filter_values
    {
      keywords: params[:selected_keywords],
      subjects: params[:selected_subjects],
      type_name: params[:selected_types],
      levels: params[:selected_levels],
      bookmarked_question_ids: params[:bookmarked_question_ids],
      bookmarked: ActiveModel::Type::Boolean.new.cast(params[:bookmarked]),
      user: current_user,
      filter_my_questions:,
      user_ids: current_user.admin? ? Array.wrap(params[:selected_users]).map(&:to_i) : []
    }
  end

  def filter_my_questions
    ActiveModel::Type::Boolean.new.cast(params[:filter_my_questions])
  end
end
