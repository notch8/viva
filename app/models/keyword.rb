# frozen_string_literal: true

class Keyword < ApplicationRecord
  has_and_belongs_to_many :questions
  validates :name, presence: true, uniqueness: true

  self.implicit_order_column = :name
end
