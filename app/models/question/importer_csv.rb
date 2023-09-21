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
  ##
  # @todo Maybe we don't want to read the given CSV and pass the text into the object.  However,
  #       that is a later concern refactor that should be relatively easy given these various
  #       inflection points.
  def self.from_file(csv)
    new(csv.read)
  end

  def initialize(text)
    @errors = []
    @text = text
  end
  attr_reader :errors

  def save
    @questions = []
    @errors = []

    # The header_converters ensures that we don't have squirelly little BOM characters and that all
    # columns are titlecase which we later expect.
    CSV.parse(@text, headers: true, skip_blanks: true, header_converters: ->(h) { h.to_s.strip.upcase.delete("\xEF\xBB\xBF") }, encoding: 'utf-8') do |row|
      question = Question.build_from_csv_row(row)
      @errors << { row: row.to_hash, errors: question.errors.to_hash } unless question.valid?
      @questions << question
    end

    return false if @errors.present?

    @questions.all?(&:save!)
  end

  def as_json(*args)
    { questions: @questions.as_json(*args), errors: @errors.as_json(*args) }
  end
end
