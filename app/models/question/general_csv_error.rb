# frozen_string_literal: true

##
# A question type wrapper for when we encounter a general CSV error.  This little wrapper helps us
# render a common object for sending the error message back to the client.
class Question::GeneralCsvError
  ##
  # @param exception [StandardError, CSV::MalformedCSVError]
  def initialize(exception:)
    @exception = exception
  end

  def valid?
    false
  end

  def errors
    {
      message: @exception.message
    }
  end
end
