# frozen_string_literal: true

# OVERRIDE Devise to not allow users to register or delete their own account

class RegistrationsController < Devise::RegistrationsController
  def new
    raise ActionController::RoutingError, 'Not Found'
  end

  def create
    raise ActionController::RoutingError, 'Not Found'
  end

  def destroy
    raise ActionController::RoutingError, 'Not Found'
  end
end
