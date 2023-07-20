# frozen_string_literal: true

require 'faker'

# HomeController
class HomeController < ApplicationController
  def index
    render inertia: 'App', props: {
      name: Faker::Name.name
    }
  end
end
