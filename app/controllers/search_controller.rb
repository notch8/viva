# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  include Pagy::Backend
  include QuestionFilterParams

  def index
    render inertia: 'Search', props: shared_props
  end

  private

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def shared_props
    base_query = Question.filter_query(search: params[:search], filter_my_questions: question_filter_my_questions, **question_filter_values)
    query = base_query.reorder(updated_at: :desc)

    @pagy, @questions_page = pagy(query)

    bookmarked_question_ids = current_user.bookmarks.pluck(:question_id)

    # Check if all filtered questions are already bookmarked
    # Try to get all filtered IDs, but handle SQL errors gracefully
    all_filtered_bookmarked = false
    begin
      # Get IDs from the base query without includes/selects that cause ambiguity
      all_filtered_question_ids = base_query.except(:includes, :select).pluck(:id)
      all_filtered_bookmarked = all_filtered_question_ids.present? && (all_filtered_question_ids - bookmarked_question_ids).empty?
    rescue ActiveRecord::StatementInvalid
      # If SQL error (e.g., ambiguous column), fall back to checking current page only
      current_page_ids = @questions_page.pluck(:id)
      all_filtered_bookmarked = current_page_ids.present? && (current_page_ids - bookmarked_question_ids).empty? && @pagy.pages <= 1
    end

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
      filterMyQuestions: question_filter_my_questions,

      # Pass the formatted page
      filteredQuestions: serialized_questions,

      # Pass the metadata
      pagination: pagy_metadata(@pagy),

      bookmarkedQuestionIds: bookmarked_question_ids,
      allFilteredBookmarked: all_filtered_bookmarked,
      lms: Question.lms
    }

    if current_user.admin?
      props[:users] = User.order(:email).pluck(:id, :email).map { |id, email| { id:, email: } }
      props[:selectedUsers] = params[:selected_users]
    end

    props
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
