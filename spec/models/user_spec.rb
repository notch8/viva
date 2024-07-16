# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:bookmarks).dependent(:destroy) }
  it { should have_many(:bookmarked_questions).through(:bookmarks).source(:question) }
end
