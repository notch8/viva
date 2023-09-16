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
      filtered_questions: Question.filter_as_json(
               keywords: params[:keywords],
               categories: params[:categories],
               # Deprecating :type; I'd prefer us to use :type_name
               type_name: params[:type_name] || params[:type]
             )
    }
  end
end
