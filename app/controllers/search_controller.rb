# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  def index
    render inertia: 'Search', props: shared_props
  end

  def filtered_questions
    Question.filter_as_json(
      keywords: params[:selected_keywords],
      subjects: params[:selected_subjects],
      # Deprecating :type; I'd prefer us to use :type_name
      type_name: params[:selected_types],
      levels: params[:selected_levels]
    )
  end

  # rubocop:disable Metrics/MethodLength
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
      filteredQuestions: filtered_questions,
      exportURL: export_url
    }
  end
  # rubocop:enable Metrics/MethodLength

  def export_url
    # create_new_export
    # set the exportURL prop to the resulting URL of the export. for now, we are using a dummy URL to set up the download functionality in the UI
    ".xml#{request.original_fullpath.slice(1..-1)}"
  end

  def create_new_export
    # add logic to create an export with the provided filtered questions here once the export model & functionality are created.
    # Export.create(filtered_questions)... etc
    raise 'Not implemented yet'
  end

  private

  def search_params
    params.permit(:selected_keywords, :selected_subjects, :selected_types, :selected_levels)
  end
end
