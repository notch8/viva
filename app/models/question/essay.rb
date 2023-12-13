# frozen_string_literal: true

##
# One question that involves a lengthy introduction to the concept and has a "Rich Text" ask.
#
# @note the {#data} attribute will be a Hash with one key: "html".  That "html" will be safe to
#       render in the UI.
class Question::Essay < Question
  include MarkdownQuestionBehavior

  self.type_name = "Essay"
  self.export_as_xml = true

  class ImportCsvRow < MarkdownQuestionBehavior::ImportCsvRow
  end
end
