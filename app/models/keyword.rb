# frozen_string_literal: true

##
# The "tags" associated with one or more questions.
class Keyword < ApplicationRecord
  has_and_belongs_to_many :questions
  validates :name, presence: true, uniqueness: true

  self.implicit_order_column = :name

  ##
  # @return [Array<String>] an alphabetized list of keyword names.
  def self.names
    all.order(name: :asc).pluck(:name)
  end
end
