# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  # inertia_share is a method provided by the inertia_rails gem
  # it defines props automatically included in every Inertia response
  # it's analogous to before_action but for Inertia props rather than controller logic
  inertia_share do
    {
      currentUser: current_user&.as_json(only: [:id, :email, :admin])
    }
  end
end
