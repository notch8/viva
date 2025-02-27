# frozen_string_literal: true

##
# Error message that is returned when the SUBJECT given is unexpected.
#
class Question::InvalidSubject < Question::InvalidQuestion
  def message
    "row had SUBJECT of #{row['SUBJECT']} but expected only include the following: #{Subject.names.map { |name| name }.join(', ')}"
  end
end
