# frozen_string_literal: true

##
# A question to be asked.
#
# @note This is an abstract class that leverages single-table inheritance (STI).  There are
#       subclasses found in the app/models/question directory.
class Question < ApplicationRecord
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :keywords

  ##
  # @see {Question::StimulusCaseStudy} for aggregation.
  has_one :as_child_question_aggregations, class_name: 'QuestionAggregation', dependent: :destroy, as: :child_question
  has_one :parent_question, through: :as_child_question_aggregations, class_name: "Question", source_type: "Question"

  validates :text, presence: true
  validates :type, presence: true

  validate :type_must_be_for_descendant

  def type_must_be_for_descendant
    # We're using `Question` instead of `self.class` because this method propogates to the subclasses
    # which will result in different set of descendants.
    klass_names = Question.types
    return true if klass_names.include?(type.to_s)

    errors.add(:type, "was #{type} but must be one of the following: #{klass_names.inspect}")
  end
  private :type_must_be_for_descendant

  ##
  # @return [Array<String>]
  def self.types
    Question.descendants.map { |klass| klass.model_name.name }
  end

  ##
  # Read through the given :csv and create the corresponding questions.
  #
  # @param csv [CSV]
  #
  # @todo Given that they are uploading a CSV and there's significant validation, we're almost
  #       certainly going to want an object to handle the importer and tracking of what worked and
  #       what failed.  But that's a not yet problem.
  def self.import_csv(csv)
    csv.each do |row|
      type = row.fetch('TYPE')
      klass = "Question::#{type}".constantize
      klass.import_csv_row(row)
    end
  end

  def self.import_csv_row(*args)
    raise NotImplementedError, "#{self}.#{__method__}"
  end

  ##
  # Filter questions by keywords and/or categories.
  #
  # We omit questions that are part of a {QuestionAggregation} (e.g. those that are children to a
  # {Question::StimulusCaseStudy}.
  #
  # @param keywords [Array<String>] when provided, a question must have all of the given keywords.
  # @param categories [Array<String>] when provided, a question must have all of the provided
  #        categories.
  # @param type [String,NilClass] when present, filter questions to only include the given type.
  # @param selected_attributes [Array<Symbol>] the attributes to include in the filter.  By
  #        narrowing the selection of attributes we reduce the computational cost of generating the
  #        query result set (e.g. we don't have to serialize/send/deserialize un-used columns.
  #        *NOTE:* You must include the :type column if you want to leverage the inheritance.
  #
  # @return [ActiveRecord::Relation<Question>] Each {Question} will have only the selected
  #         attributes (e.g. by default they won't have the :created_at, :updated_at, etc
  #         attributes).
  #
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.filter(keywords: [], categories: [], type: nil, selected_attributes: [:id, :text, :type])
    # By wrapping in an array we ensure that our keywords.size and categories.size are counting
    # the number of keywords given and not the number of characters in a singular keyword that was
    # provided.
    keywords = Array.wrap(keywords)
    categories = Array.wrap(categories)

    questions = Question.select(*selected_attributes).where(child_of_aggregation: false)

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

    if type.present?
      # TODO: Consider how we coerce the user input to the correct type.  The type stored will be
      # of the form "Question::Matching".
      questions = questions.where(type:)
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
