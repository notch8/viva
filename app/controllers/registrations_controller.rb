# frozen_string_literal: true

# OVERRIDE Devise to not allow users to register

class RegistrationsController < Devise::RegistrationsController
  def new
    raise ActionController::RoutingError, 'Not Found'
  end

  def create
    raise ActionController::RoutingError, 'Not Found'
  end
end
