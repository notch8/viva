# frozen_string_literal: true

##
# The categorization for questions.
class Subject < ApplicationRecord
  has_and_belongs_to_many :questions
  validates :name, presence: true, uniqueness: true

  self.implicit_order_column = :name

  ##
  # @return [Array<String>] an alphabetized list of subject names.
  def self.names
    order(name: :asc).pluck(:name)
  end

  before_save :downcase_name

  def downcase_name
    self.name = name.downcase
  end
end
