# frozen_string_literal: true

##
# A faux-question that we can return as part of the CSV import to communicate the problem around not
# having a TYPE column in the import.
class Question::NoType < Question::InvalidQuestion
  def message
    "row did not have TYPE column"
  end
end
