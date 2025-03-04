# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  def index
    render inertia: 'Search', props: shared_props
  end

  def create_bookmarks
    result = Bookmark.create_batch(question_ids: params[:filtered_ids], user: current_user)
    if result == :error
      redirect_back(fallback_location: authenticated_root_path, notice: t('.failure'))
    else
      redirect_back(fallback_location: authenticated_root_path, notice: t('.success'))
    end
  end

  # private

  def shared_props
    {
      keywords: Keyword.names,
      subjects: Subject.names,
      types: Question.type_names, # Deprecated Favor :type_names
      type_names: Question.type_names,
      levels: Level.names,
      selectedKeywords: params[:selected_keywords],
      selectedSubjects: params[:selected_subjects],
      selectedTypes: params[:selected_types],
      selectedLevels: params[:selected_levels],
      filteredQuestions: Question.filter_as_json(search: params[:search], **filter_values),
      bookmarkedQuestionIds: current_user.bookmarks.pluck(:question_id)
    }
  end

  def filter_values
    {
      keywords: params[:selected_keywords],
      subjects: params[:selected_subjects],
      type_name: params[:selected_types],
      levels: params[:selected_levels],
      bookmarked_question_ids: params[:bookmarked_question_ids],
      bookmarked: ActiveModel::Type::Boolean.new.cast(params[:bookmarked]),
      user: current_user
    }
  end
end
