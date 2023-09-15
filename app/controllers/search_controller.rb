# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  def index
    render inertia: 'Search', props: {
      keywords: Keyword.all.pluck(:name),
      categories: Category.all.pluck(:name),
      types: Question.types,
    #   filtered_questions: [
    #     {
    #       id: 1,
    #       text: 'What is the meaning of life?',
    #       answers: ['This is an answer to the meaning of life.', 'This is another answer to the meaning of life.', 'This is a third answer to the meaning of life.', 'This is a fourth answer to the meaning of life.'],
    #       incorrect_answers: ['one'],
    #       type: 'Question::Traditional',
    #       keywords: ['meaning', 'life'],
    #       categories: ['history'],
    #       level: '1',
    #     },
    #     {
    #       id: 2,
    #       text: 'What is the meaning of life?',
    #       answers: ['This is an answer to the meaning of life.', 'This is another answer to the meaning of life.', 'This is a third answer to the meaning of life.', 'This is a fourth answer to the meaning of life.'],
    #       incorrect_answers: [],
    #       type: 'Question::Traditional',
    #       keywords: ['meaning', 'life'],
    #       categories: ['history'],
    #       level: '1',
    #     },
    #     {
    #       id: 3,
    #       text: 'What is the meaning of life?',
    #       answers: ['This is an answer to the meaning of life.', 'This is another answer to the meaning of life.', 'This is a third answer to the meaning of life.', 'This is a fourth answer to the meaning of life.'],
    #       type: 'Question::Traditional',
    #       keywords: ['meaning', 'life'],
    #       categories: ['nursing'],
    #       level: '1',
    #     },
    #   ]
    # }
      filtered_questions: Question.filter_as_json(
                keywords: params[:keywords],
                categories: params[:categories],
                type: params[:type]
              )
            }
  end
end
