# frozen_string_literal: true

##
# The controller to handle methods related to the uploads page.
class UploadsController < ApplicationController
  def index
    render inertia: 'Uploads'
  end

  def create
    temp_file = create_params['0'].tempfile
    @questions = Question::ImporterCsv.from_file(temp_file)
    if @questions.save
      render inertia: 'Uploads', props: @questions.as_json, status: :created
    else
      # note that the errors are automatically passed in the props as part of questions
      render inertia: 'Uploads', props: @questions.as_json, status: :unprocessable_entity
    end
  end

  def create_params
    params.require(:csv)
  end
end
