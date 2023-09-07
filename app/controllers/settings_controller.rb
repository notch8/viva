# frozen_string_literal: true

##
# The controller to handle methods related to the settings page.
class SettingsController < ApplicationController
  def index
    render inertia: 'Settings'
  end
end
