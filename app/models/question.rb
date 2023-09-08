# frozen_string_literal: true

##
# A question to be asked.
class Question < ApplicationRecord
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :keywords
  validates :text, presence: true

  ##
  # Filter questions by keywords and/or categories.
  #
  # @param keywords [Array<String>] when provided, a question must have all of the given keywords.
  # @param categories [Array<String>] when provided, a question must have all of the provided
  #        categories.
  # @param selected_attributes [Array<Symbol>] the attributes to include in the filter.  By
  #        narrowing the selection of attributes we reduce the computational cost of generating the
  #        query result set (e.g. we don't have to serialize/send/deserialize un-used columns.
  #
  # @return [ActiveRecord::Relation<Question>] Each question will have only the selected attributes.
  #
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.filter(keywords: [], categories: [], selected_attributes: [:id, :text])
    # By wrapping in an array we ensure that our keywords.size and categories.size are counting
    # the number of keywords given and not the number of characters in a singular keyword that was
    # provided.
    keywords = Array.wrap(keywords)
    categories = Array.wrap(categories)

    questions = Question.select(*selected_attributes).all

    if keywords.present?
      # NOTE: This assumes that we don't persist duplicate pairings of question/keyword; this is
      # enforced in the database schema via a unique index.
      keywords_subquery = Keyword.select(:question_id)
                                 .joins(:keywords_questions)
                                 .where(name: keywords)
                                 .group(:question_id)
                                 .having('count(question_id) = ?', keywords.size)
      # We sanitize the subquery via Arel.  The above construction is adequate.
      questions = questions.where(Arel.sql("id IN (#{keywords_subquery.to_sql})"))
    end

    if categories.present?
      # NOTE: This assumes that we don't persist duplicate pairings of question/cateogry; this is
      # enforced in the database schema via a unique index.
      categories_subquery = Category.select('question_id')
                                    .joins(:categories_questions)
                                    .where(name: categories)
                                    .having('count(question_id) = ?', categories.size)
                                    .group('question_id')
      # We sanitize the subquery via Arel.  The above construction is adequate.
      questions = questions.where(Arel.sql("id IN (#{categories_subquery.to_sql})"))
    end

    questions
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
