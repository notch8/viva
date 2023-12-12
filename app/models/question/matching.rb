# frozen_string_literal: true

##
# A matching {Question}'s data includes pairs (e.g. A goes to B, C goes to D).
#
# @see #well_formed_serialized_data
class Question::Matching < Question
  self.type_name = "Matching"
  self.export_as_xml = true

  class ImportCsvRow < MatchingQuestionBehavior::ImportCsvRow
  end

  include MatchingQuestionBehavior

  self.choice_cardinality_is_multiple = false
end
