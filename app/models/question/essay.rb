# frozen_string_literal: true

##
# One question that involves a lengthy introduction to the concept and has a "Rich Text" ask.
#
# @note the {#data} attribute will be a Hash with one key: "html".  That "html" will be safe to
#       render in the UI.
class Question::Essay < Question
  self.type_name = "Essay"

  include MarkdownQuestionBehavior
  class ImportCsvRow < MarkdownQuestionBehavior::ImportCsvRow
  end
end
