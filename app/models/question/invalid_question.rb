# frozen_string_literal: true

##
# A faux-question that we can return as part of the CSV import to communicate a problem described
# by the {#message}
class Question::InvalidQuestion
  include ActiveModel::Validations

  def initialize(row)
    @row = row
  end

  attr_reader :row

  validate :never_shall_i_be_valid!

  def never_shall_i_be_valid!
    errors.add(:base, message)
  end
  private :never_shall_i_be_valid!

  def message
    raise NotImplementedError, "#{self.class}##{__method__}"
  end
end
