# frozen_string_literal: true

##
# The controller to handle methods related to the uploads page.
class UploadsController < ApplicationController
  def index
    render inertia: 'Uploads'
  end

  def create
    @questions = Question::ImporterCsv.from_file(create_params)
    if @questions.save
      render inertia: 'Uploads', props: @questions.as_json, status: :created
    else
      render inertia: 'Uploads', props: @questions.as_json, status: :unprocessable_entity
    end
  end

  def create_params
    params.require(:csv)
  end
end
