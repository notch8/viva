# frozen_string_literal: true

##
# Controller to handle plain text downloads of questions
class PlainTextDownloadsController < ApplicationController
  def download
    questions = Question.where(id: Bookmark.select(:question_id))
    content = questions.map { |question| QuestionTextFormatterService.new(question).format }.join('')
    send_data content, filename: 'questions.txt', type: 'text/plain'
  end
end
