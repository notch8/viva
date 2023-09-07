# frozen_string_literal: true

##
# @see Question
class QuestionsController < ApplicationController
  def index
    @questions = Question.filter(keywords: params[:keywords], categories: params[:categories])
    respond_to do |wants|
      wants.html
      wants.json { render json: @questions }
    end
  end
end
