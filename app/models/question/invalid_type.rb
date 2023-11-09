# frozen_string_literal: true

##
# A faux-question that we can return as part of the CSV import to communicate the problem around having
# having a TYPE that is unexpected.
#
# @see {Question}
class Question::InvalidType < Question::InvalidQuestion
  def message
    "row had TYPE of #{row['TYPE'].inspect} but expected to be one of the following: #{Question.descendants.map(&:type_name).join(', ')}"
  end
end
