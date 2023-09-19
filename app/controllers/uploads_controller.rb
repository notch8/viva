# frozen_string_literal: true

##
# The controller to handle methods related to the uploads page.
class UploadsController < ApplicationController
  def index
    render inertia: 'Uploads'
  end

  def create
    # TODO: Build out this method to actually upload the csv
    Rails.logger.info params[:csv]
    render inertia: 'Uploads'
  end
end
