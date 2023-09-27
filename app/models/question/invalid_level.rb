# frozen_string_literal: true

##
# Error message that is returned when the LEVEL given is unexpected.
#
class Question::InvalidLevel < Question::InvalidQuestion
  def message
    "row had LEVEL of #{row['LEVEL']} but expected to be one of the following: #{Level.names.map{ |name| name }.join(', ')}"
  end
end
