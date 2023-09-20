# frozen_string_literal: true

##
# The controller to handle methods related to the settings page.
class SettingsController < ApplicationController
  def index
    render inertia: 'Settings', props: {
      currentUser: current_user
    }
  end

  def update
    if current_user.update(user_params)
      redirect_to settings_path, notice: 'Settings updated successfully'
    else
      render inertia: 'Settings', props: {
        currentUser: current_user,
        errors: current_user.errors.as_json
      }
    end
  end

  def update_password
    if current_user.update_with_password(password_params)
      bypass_sign_in(current_user)
      redirect_to settings_path, notice: 'Password updated successfully'
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

  def password_params
    params.permit(:current_password, :password, :password_confirmation)
  end
end
