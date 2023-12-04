# frozen_string_literal: true

##
# A matching {Question}'s data includes pairs (e.g. A goes to B, C goes to D).
#
# @see #well_formed_serialized_data
class Question::Categorization < Question
  self.type_name = "Categorization"

  class ImportCsvRow < MatchingQuestionBehavior::ImportCsvRow
  end

  include MatchingQuestionBehavior
end
