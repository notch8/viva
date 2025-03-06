# frozen_string_literal: true

##
# A matching {Question}'s data includes pairs (e.g. A goes to B, C goes to D).
#
# @see #well_formed_serialized_data
class Question::Matching < Question
  include MatchingQuestionBehavior

  self.type_name = "Matching"
  self.model_exporter = 'matching_type'
  self.blackboard_export_type = 'MAT'
  self.moodle_type = 'matching'
  self.export_as_xml = true
  self.choice_cardinality_is_multiple = false

  class ImportCsvRow < MatchingQuestionBehavior::ImportCsvRow
  end
end
