# frozen_string_literal: true

# PagesController
class PagesController < ApplicationController
  def index; end

  def other
    render inertia: 'Other'
  end
end
