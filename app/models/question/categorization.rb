# frozen_string_literal: true

##
# A categorization {Question}'s data includes pairs (e.g. A goes to B, C goes to D).
#
# @see #well_formed_serialized_data
class Question::Categorization < Question
  include MatchingQuestionBehavior

  self.type_name = "Categorization"
  self.model_exporter = 'categorization'
  self.export_as_xml = true
  self.choice_cardinality_is_multiple = true

  class ImportCsvRow < MatchingQuestionBehavior::ImportCsvRow
  end
end
