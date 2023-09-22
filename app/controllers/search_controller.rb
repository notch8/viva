# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  # rubocop:disable Metrics/MethodLength
  def index
    render inertia: 'Search', props: {
      keywords: Keyword.names,
      categories: Category.names,
      types: Question.type_names, # Deprecated Favor :type_names
      type_names: Question.type_names,
      levels: Level.names,
      selectedKeywords: params[:selected_keywords],
      selectedCategories: params[:selected_categories],
      selectedTypes: params[:selected_types],
      # TODO: Add :levels once it is set up in the back end
      filteredQuestions: Question.filter_as_json(
               keywords: params[:selected_keywords],
               categories: params[:selected_categories],
               # Deprecating :type; I'd prefer us to use :type_name
               type_name: params[:selected_types]
               # TODO: Add :levels once it is set up in the back end
               # level: params[:selected_levels]
             )
    }
  end
  # rubocop:enable Metrics/MethodLength

  private

  def filter_params
    params.permit(:selected_keywords, :selected_categories, :selected_types, :selected_levels)
  end
end
