# frozen_string_literal: true

##
# When the CSV question we're parsing does not have the {#expected} headers, report an error with
# that.
class Question::ExpectedColumnMissing
  # @param expected [Array<#to_s>]
  # @param given [Array<#to_s>]
  def initialize(expected:, given:)
    @expected = expected
    @given = given
    @missing = expected & given
  end

  def valid?
    false
  end

  def errors
    {
      expected: @expected,
      given: @given,
      missing: @missing
    }
  end
end
