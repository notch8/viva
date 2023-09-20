# frozen_string_literal: true

##
# The {Question::ImporterCsv} is responsible for:
#
# 1. Receiving a CSV and first looping over all records ensuring their validity.
#    a. And when there is one or more invalid records, reporting those invalid records (without
#       persisting any of the records)
#    b. And when all records are valid, persisting those records.
# 2. Negotiating the parent/child relationship of {Question::StimulusCaseStudy} and it's
#    {Question::Scenario} children as well as other children {Question} objects.
class Question::ImporterCsv
  def initialize(text)
    @errors = []
    @text = text
  end
  attr_reader :errors

  def save
    @questions = []
    @errors = []

    # TODO: Do we want to assume text?  That means we slurp the whole file.  But for now, this
    # works.
    CSV.parse(@text, headers: true, skip_blanks: true, encoding: 'utf-8') do |row|
      question = Question.build_from_csv_row(row)
      @errors << { row: row.to_hash, errors: question.errors.to_hash } unless question.valid?
      @questions << question
    end

    return false if @errors.present?

    @questions.all?(&:save!)
  end
end
