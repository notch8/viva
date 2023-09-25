# frozen_string_literal: true

##
# A question to be asked.
#
# @note This is an abstract class that leverages single-table inheritance (STI).  There are
#       subclasses found in the app/models/question directory.
#
# rubocop:disable Metrics/ClassLength
class Question < ApplicationRecord
  has_and_belongs_to_many :categories, -> { order(name: :asc) }
  has_and_belongs_to_many :keywords, -> { order(name: :asc) }

  class_attribute :type_label, default: "Question", instance_writer: false
  class_attribute :type_name, default: "Question", instance_writer: false
  class_attribute :include_in_filterable_type, default: true, instance_writer: false

  class_attribute :require_csv_headers, default: %w[IMPORT_ID TEXT TYPE].freeze

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
    klass_names = Question.descendants.map { |descendant| descendant.model_name.name }
    return true if klass_names.include?(type.to_s)

    errors.add(:type, "was #{type} but must be one of the following: #{klass_names.inspect}")
  end
  private :type_must_be_for_descendant

  ##
  # {Question#type} is a partially reserved value; used for the Single Table Inheritance.  It is not
  # human friendly.  The {.type_names} is an effort to be more friendly.
  #
  # @return [Array<String>]
  def self.type_names
    Question.descendants.each_with_object([]) do |descendant, array|
      array << descendant.type_name if descendant.include_in_filterable_type
    end
  end

  ##
  # @param name [String]
  #
  # @return [Class<Question>]
  # @return [NilClass] when the given name is not a valid {.type_name}
  def self.type_name_to_class(name, fallback: Question)
    Question.descendants.detect { |d| d.type_name == name || d == name } || fallback
  end

  def self.build_row(*args)
    raise NotImplementedError, "#{self}.#{__method__}"
  end

  ##
  # @see Question::ImporterCsv
  #
  # @param row [Enumerable] likely a row from {CSV.read}.
  # @return [Question] a subclass of {Question} derived from the row's TYPE property.
  # @return [Question::InvalidQuestion] when we have a row that doesn't have adequate information to
  #         build the proper {Question} subclass.
  def self.build_from_csv_row(row)
    return Question::NoType.new(row) unless row['TYPE']
    return Question::NoImportId.new(row) unless row['IMPORT_ID']

    klass = Question.type_name_to_class(row['TYPE'], fallback: nil)

    return Question::InvalidType.new(row) unless klass

    klass.build_row(row)
  end

  FILTER_DEFAULT_SELECT = [:id, :data, :text, :type, :keyword_names, :category_names].freeze
  FILTER_DEFAULT_METHODS = [:level, :type_label, :type_name, :data].freeze

  ##
  # @param select [Array<Symbol>] attribute names both passed forward to {.filter} and exposed in
  #        the resulting JSON object (in addition to those specified in :method).
  # @param methods [Array<Symbol>] attribute names to include in the JSON document.
  # @param kwargs [Hash<Symbol,Object>] values passed forward to {.filter}
  #
  # @note Why {.filter} and {.filter_as_json}?  There are two reasons: 1) we are interested in the
  #       STI field of :type and by default that is not something included in the base {#as_json}
  #       behavior; 2) we want to include keyword_names and category_names.
  #
  #       The keyword_names and category_names are constructed differently so as to minimize
  #       database queries.  I had tried to use keywords and categories, but those are relations and
  #       behave a bit differently.  You'll want to look at the specs to see how this resolves.
  #
  # @return [Array<Hash>] A Ruby array of hashes where the hashes have the the keys specified in the
  #         :select parameter.
  #
  # @see .filter
  def self.filter_as_json(select: FILTER_DEFAULT_SELECT, methods: FILTER_DEFAULT_METHODS, **kwargs)
    ##
    # The :data method/field is an interesting creature; we want to "select" it in queries because
    # in most cases that is adequate.  Yet the {Question::StimulusCaseStudy#data} is unique, in that
    # it uses the {Question::StimulusCaseStudy#child_questions} to build the data.
    #
    # Hence we want to :select that data for querying, but rely instead on the :method.
    only = select - methods
    filter(select:, **kwargs).as_json(only:, methods:)
  end

  ##
  # @todo A placeholder for future properties/values
  def level
    1
  end

  ##
  # @param row [CsvRow]
  # @return [Array<String>]
  def self.extract_category_names_from(row)
    row.flat_map { |header, value| value.split(/\s*,\s*/).map(&:strip) if header.present? && (header == "CATEGORIES" || header == "CATEGORY" || header.start_with?("CATEGORY_")) }.compact.sort
  end
  private_class_method :extract_category_names_from

  ##
  # @param row [CsvRow]
  # @return [Array<String>]
  def self.extract_keyword_names_from(row)
    row.flat_map { |header, value| value.split(/\s*,\s*/).map(&:strip) if header.present? && (header == "KEYWORDS" || header == "KEYWORD" || header.start_with?("KEYWORD_")) }.compact.sort
  end
  private_class_method :extract_keyword_names_from

  ##
  # This method ensures that we will consistently have a Question#keyword_names regardless of
  # whether the underlying query to reify the Question had a select statement that included the
  # "keyword_names" query field.
  #
  # @return [Array<String>]
  #
  # @see .filter_as_json
  # @see #find_or_create_categories_and_keywords
  def keyword_names
    @keyword_names.presence || attributes.fetch(:keyword_names) { keywords.map(&:name) } || []
  end

  ##
  # @see #find_or_create_categories_and_keywords
  attr_writer :keyword_names

  ##
  # This method ensures that we will consistently have a Question#category_names regardless of
  # whether the underlying query to reify the Question had a select statement that included the
  # "category_names" query field.
  #
  # @return [Array<String>]
  #
  # @see .filter_as_json
  # @see #find_or_create_categories_and_keywords
  def category_names
    @category_names.presence || attributes.fetch(:category_names) { categories.map(&:name) } || []
  end
  ##
  # @see #find_or_create_categories_and_keywords
  attr_writer :category_names

  after_save :find_or_create_categories_and_keywords

  ##
  # As part of the {.build_from_csv_row}, the subclasses are assigning the `@category_names' and
  # `@keyword_names'.  When we save a record being imported, we want to persist those values to the
  # corresponding relationships (e.g. {#categories} and {#keywords}).
  def find_or_create_categories_and_keywords
    @category_names&.each do |name|
      categories << Category.find_or_create_by(name:)
    end
    @category_names = nil

    @keyword_names&.each do |name|
      keywords << Keyword.find_or_create_by(name:)
    end
    @keyword_names = nil
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
  # @param type_name [String,NilClass] when present, filter questions to only include the given
  #        type.
  # @param select [Array<Symbol>] the attributes to include in the filter.  By narrowing the
  #        selection of attributes we reduce the computational cost of generating the query result
  #        set (e.g. we don't have to serialize/send/deserialize un-used columns.  *NOTE:* You must
  #        include the :type column if you want to leverage the inheritance.
  #
  # @return [ActiveRecord::Relation<Question>] Each {Question} will have only the selected
  #         attributes (e.g. by default they won't have the :created_at, :updated_at, etc
  #         attributes).
  #
  # @see .filter_as_json
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.filter(keywords: [], categories: [], type_name: nil, select: nil)
    # By wrapping in an array we ensure that our keywords.size and categories.size are counting
    # the number of keywords given and not the number of characters in a singular keyword that was
    # provided.
    keywords = Array.wrap(keywords)
    categories = Array.wrap(categories)

    # Specifying a very arbitrary order
    questions = Question.order(:id)

    # We want a human readable name for filtering and UI work.  However, we want to convert that
    # into a class.  ActiveRecord is mostly smart about Single Table Inheritance (STI).  But we're
    # not doing something like `Question::Traditional.where`; but instead `Question.where(type:
    # "Question::Traditional")`.  The below code will ensure that the named type and any child
    # descendants are used in the where clause.
    types = Array.wrap(type_name).flat_map do |name|
      klass = type_name_to_class(name)
      [klass.sti_name] + klass.descendants.map(&:sti_name)
    end
    questions = questions.where(type: types) if types.present?

    questions = questions.where(child_of_aggregation: false)

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

    return questions if select.blank?

    # The following for category_names and keyword_names is to reduce the number of queries we send
    # to the database.  By favoring this mechanism we create the virtual attributes of
    # :category_names and :keyword_names.
    #
    # We duplicate this as that results in an unfrozen array which we then proceed to modify
    select_statement = select.dup

    if select.include?(:category_names)
      select_statement.delete(:category_names)
      select_statement << %((SELECT ARRAY_AGG (categories.name) AS kws
        FROM categories
        INNER JOIN categories_questions ON categories.id = categories_questions.category_id
        INNER JOIN questions AS inner_q ON categories_questions.question_id = questions.id
        WHERE inner_q.id = questions.id) AS "category_names")
    end

    if select.include?(:keyword_names)
      select_statement.delete(:keyword_names)
      select_statement << %((SELECT ARRAY_AGG (keywords.name) AS kws
        FROM keywords
        INNER JOIN keywords_questions ON keywords.id = keywords_questions.keyword_id
        INNER JOIN questions AS inner_q ON keywords_questions.question_id = questions.id
        WHERE inner_q.id = questions.id) AS "keyword_names")
    end

    questions.select(*select_statement)
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end

# rubocop:enable Metrics/ClassLength
