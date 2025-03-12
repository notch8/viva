# frozen_string_literal: true

##
# One question that involves a lengthy introduction to the concept and has a "Rich Text" ask; and
# requires the answer to be an uploaded file.
#
# @note the {#data} attribute will be a Hash with one key: "html".  That "html" will be safe to
#       render in the UI.
class Question::Upload < Question
  include MarkdownQuestionBehavior

  self.type_name = "Upload"
  self.model_exporter = 'essay_type'
  self.canvas_export_type = true
  self.d2l_export_type = 'WR'

  def self.display_name
    "File Upload"
  end

  class ImportCsvRow < MarkdownQuestionBehavior::ImportCsvRow
  end
end
