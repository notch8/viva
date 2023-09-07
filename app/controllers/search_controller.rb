# frozen_string_literal: true

require 'faker'

class SearchController < ApplicationController
  def index
    render inertia: 'Search', props: {
      name: Faker::Name.name # this is not being used, just leaving it so we remember how to pass props
    }
  end
end
