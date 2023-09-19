# frozen_string_literal: true

##
# The controller to handle methods related to the uploads page.
class UploadsController < ApplicationController
  def index
    render inertia: 'Uploads'
  end

  def create
    puts params[:csv]
    render inertia: 'Uploads'
  end
end
