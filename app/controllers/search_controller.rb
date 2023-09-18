# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  def index
    render inertia: 'Search', props: {
      keywords: Keyword.all.pluck(:name),
      categories: Category.all.pluck(:name),
      types: Question.type_names, # Deprecated Favor :type_names
      type_names: Question.type_names,
      levels: [1, 2, 3], # hard coding this for now - allows there to be levels in the UI dropdown
      filtered_questions: Question.filter_as_json(
               keywords: params[:selected_keywords],
               categories: params[:selected_categories],
               # Deprecating :type; I'd prefer us to use :type_name
               type_name: params[:selected_types]
               # TODO: Add :levels once it is set up in the back end
               # level: params[:selected_levels]
             )
    }
  end

  private

  def filter_params
    params.permit(:selected_keywords, :selected_categories, :selected_types, :selected_levels)
  end
end
