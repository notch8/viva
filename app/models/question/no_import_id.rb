# frozen_string_literal: true

##
# A faux-question that we can return as part of the CSV import to communicate the problem of not
# having an IMPORT_ID column.
class Question::NoImportId < Question::InvalidQuestion
  def message
    "row did not have IMPORT_ID column"
  end
end
