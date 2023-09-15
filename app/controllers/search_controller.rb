# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  def index
    render inertia: 'Search', props: {
      keywords: Keyword.all.pluck(:name),
      categories: Category.all.pluck(:name),
      types: Question.type_names, # Deprecated Favor :type_names
      type_names: Question.type_names,
      filtered_questions: Question.filter_as_json(
               keywords: params[:keywords],
               categories: params[:categories],
               # Deprecating :type; I'd prefer us to use :type_name
               type_name: params[:type_name] || params[:type]
             )
      # filtered_questions: [
      #   {
      #     id: 1,
      #     text: 'What is the meaning of life?',
      #     data: [
      #       {
      #         text: 'This is an answer to the meaning of life.',
      #         correct: true
      #       }, {
      #         text: 'This is another answer to the meaning of life.',
      #         correct: false
      #       }, {
      #         text: 'This is a third answer to the meaning of life.',
      #         correct: false
      #       }, {
      #         text: 'This is a fourth answer to the meaning of life.',
      #         correct: false
      #       }
      #     ],
      #     type: 'Question::Traditional',
      #     keywords: ['meaning', 'life'],
      #     categories: ['history'],
      #     level: '1',
      #   },
      #   {
      #     id: 2,
      #     text: 'What is the meaning of life?',
      #     data: [
      #       {
      #         text: 'This is an answer to the meaning of life.',
      #         correct: false
      #       }, {
      #         text: 'This is another answer to the meaning of life.',
      #         correct: false
      #       }, {
      #         text: 'This is a third answer to the meaning of life.',
      #         correct: true
      #       }, {
      #         text: 'This is a fourth answer to the meaning of life.',
      #         correct: false
      #       }
      #     ],
      #     type: 'Question::Traditional',
      #     keywords: ['meaning', 'life'],
      #     categories: ['history'],
      #     level: '1',
      #   },
      #   {
      #     id: 3,
      #     text: 'What is the meaning of life?',
      #     data: [
      #       {
      #         text: 'This is an answer to the meaning of life.',
      #         correct: false
      #       }, {
      #         text: 'This is another answer to the meaning of life.',
      #         correct: false
      #       }, {
      #         text: 'This is a third answer to the meaning of life.',
      #         correct: false
      #       }, {
      #         text: 'This is a fourth answer to the meaning of life.',
      #         correct: true
      #       }
      #     ],
      #     type: 'Question::Traditional',
      #     keywords: ['meaning', 'life'],
      #     categories: ['nursing'],
      #     level: '1',
      #   },
      # ]
    }
  end
end
