# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  def index
    render inertia: 'Search', props: {
      keywords: Keyword.all.pluck(:name),
      categories: Category.all.pluck(:name),
      filtered_questions: Question.filter(keywords: params[:keywords], categories: params[:categories])
    }
  end
end
