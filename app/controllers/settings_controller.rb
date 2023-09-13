# frozen_string_literal: true

##
# The controller to handle methods related to the settings page.
class SettingsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render inertia: 'Settings', props: {
      currentUser: current_user,
    }
  end

  def update
    if current_user.update(user_params)
      #raise 'hell'
      redirect_to settings_path, notice: 'Settings updated successfully'
    else
      render inertia: 'Settings', props: {
        currentUser: current_user,
        errors: current_user.errors.as_json
      }
    end
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :title, :email)
  end
end
