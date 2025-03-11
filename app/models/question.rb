# frozen_string_literal: true

##
# A question to be asked.
#
# @note This is an abstract class that leverages single-table inheritance (STI).  There are
#       subclasses found in the app/models/question directory.
#
# rubocop:disable Metrics/ClassLength
class Question < ApplicationRecord
  before_save :index_searchable_field

  include PgSearch

  pg_search_scope(
    :search,
    against: %i[text searchable],
    using: { tsearch: { dictionary: "english" } }
  )

  has_and_belongs_to_many :subjects, -> { order(name: :asc) }
  has_and_belongs_to_many :keywords, -> { order(name: :asc) }
  has_many :images, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  ##
  # @!group Class Attributes

  ##
  # @!attribute has_parts
  #   @return [TrueClass] when the model is one that has parts (e.g. {Question::StimulusCaseStudy})
  #   @return [FalseClass] when the model is not one has parts (e.g. {Question::Traditional})
  class_attribute :has_parts, default: false
  class_attribute :included_in_filterable_type, default: true, instance_writer: false

  ##
  # @!attribute required_csv_headers [r|w]
  #
  #   Each question type has different required fields; the class_attribute
  #   allows us to set those values on a per type basis.
  #
  #   @return [Array<String>] the headers required for the question sub-type.
  class_attribute :required_csv_headers, default: %w[IMPORT_ID TEXT TYPE].freeze
  class_attribute :type_label, default: "Question", instance_writer: false
  class_attribute :type_name, default: "Question", instance_writer: false
  # model_exporter is the method name in the formatters used for text downloading
  # it must be defined in the inheriting classes
  class_attribute :model_exporter, default: nil, instance_writer: false
  # export_type is used as the dynamically-called method in method format_by_type in BaseService
  class_attribute :blackboard_export_type, default: nil, instance_writer: false
  class_attribute :moodle_export_type, default: nil, instance_writer: false
  class_attribute :d2l_export_type, default: nil, instance_writer: false
  ##
  # @note This is used for the Canvas LMS export.
  # @!attribute canvas_export_type [r|w]
  #   @return [TrueClass] when we can export this file as XML.
  #   @return [FalseClass] when we cannot export this file as XML.
  class_attribute :canvas_export_type, default: false, instance_writer: false, instance_reader: true, instance_predicate: true
  ##
  # @!attribute qti_max_value [r|w]
  #   @return [Integer]
  class_attribute :qti_max_value, default: 100
  # @!endgroup Class Attributes
  ##

  ##
  # @!group QTI Exporter

  ##
  # @return [String] a unique identifier for the `item` node.
  #
  # @see https://community.canvaslms.com/t5/Canvas-Question-Forum/QTI-SDK-how-to-create-Assessment-identifier-and-question-Item/m-p/547937
  def item_ident
    @item_ident ||= "item-#{assessment_question_identifierref}"
  end

  ##
  # @return [String] a unique identifier for the `fieldvalue` node
  #
  # @see https://community.canvaslms.com/t5/Canvas-Question-Forum/QTI-SDK-how-to-create-Assessment-identifier-and-question-Item/m-p/547937
  def assessment_question_identifierref
    @assessment_question_identifierref ||= Digest::SHA1.hexdigest("#{text}\n#{data}")
  end
  # @!endgroup QTI Exporter
  ##

  ##
  # A duck-typing helper method; useful when were working with a CsvImporter and want the underlying
  # question.
  #
  # @return [Question]
  def question
    self
  end

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

  def image_urls
    images.map(&:url)
  end

  def alt_texts
    images.pluck(:alt_text)
  end

  def images_as_json
    images.map do |image|
      { url: image.url, alt_text: image.alt_text }
    end
  end

  ##
  # {Question#type} is a partially reserved value; used for the Single Table Inheritance.  It is not
  # human friendly.  The {.type_names} is an effort to be more friendly.
  #
  # @return [Array<String>]
  def self.type_names
    Question.descendants.each_with_object([]) do |descendant, array|
      array << descendant.type_name if descendant.included_in_filterable_type
    end.sort
  end

  ##
  # The list of valid type names that "has_parts?"
  #
  # @return [Array<String>]
  #
  # @see .type_names
  # @see .has_parts
  def self.type_names_that_have_parts
    Question.descendants.each_with_object([]) do |descendant, array|
      array << descendant.type_name if descendant.has_parts?
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

  ##
  # Returns available question types for each supported LMS platform
  #
  # @return [Hash{Symbol => Array<String>}] Hash mapping LMS platforms to arrays of supported question type names
  #   - :blackboard - Blackboard compatible question types
  #   - :canvas - Canvas compatible question types
  #   - :moodle - Moodle compatible question types
  def self.lms
    {
      blackboard: lms_finder(:blackboard_export_type),
      d2l: lms_finder(:d2l_export_type),
      canvas: lms_finder(:canvas_export_type),
      moodle: lms_finder(:moodle_export_type)
    }
  end

  ##
  # Finds question types that support a given LMS export method
  #
  # @param lms [Symbol] The method name that indicates support for a particular LMS
  # @return [Array<String>] Sorted array of question type names that support the given LMS
  # @api private
  def self.lms_finder(lms)
    Question.descendants.select(&lms).map(&:type_name).sort
  end
  private_class_method :lms_finder

  ##
  # @abstract
  #
  # Represents the mapping process of a CSV Row to the underlying {Question}.
  #
  # The primary purpose of this class is to convey meaningful error messages for invalid CSV
  # structures.
  #
  # @see {#validate_well_formed_row}
  class ImportCsvRow
    delegate :persisted?,
             :keywords,
             :reload,
             :type_name,
             :has_parts?,
             :as_json, # When we ask self for as_json we'd get a stack level too deep error
             :to_json, # as :as_json
             to: :question
    attr_reader :text, :level, :subject_names, :keyword_names, :data
    attr_reader :row, :question_type, :questions

    def initialize(row:, question_type:, questions:)
      @row = row
      @question_type = question_type
      @questions = questions

      @text = row['TEXT']
      @level = row['LEVEL']
      @subject_names = question_type.extract_subject_names_from(row)
      @keyword_names = question_type.extract_keyword_names_from(row)

      extract_answers_and_data_from(row)
    end

    include ActiveModel::Validations

    # @note All {Question} classes validate their :text attribute
    validates :text, presence: true
    validate :validate_well_formed_row
    validate :valid_question_for_part_of

    # :nocov:
    def validate_well_formed_row
      raise NotImplementedError, "#{self}##{__method__}"
    end
    # :nocov:

    def valid_question_for_part_of
      return unless row['PART_OF']
      parent_question = questions[row['PART_OF']]
      if parent_question
        errors.add(:base, "expected PART_OF to be one of #{Question.type_names_that_have_parts.join(', ')}, got #{parent_question.type_name}.") unless parent_question.has_parts?
      else
        errors.add(:base, "expected PART_OF value to be an IMPORT_ID of another row in the CSV.")
      end
    end

    # :nocov:
    def extract_answers_and_data_from(row)
      raise NotImplementedError, "#{self}##{__method__}"
    end
    # :nocov:

    ##
    # What's happening here?  Given that we have layers of validation; it would be nice to rely on
    # the top layer first.  However, we should ask the model if the data we're providing is also
    # valid.  The model validation is less helpful for legibility; but ultimately speaks protects
    # the potential for "garbage out" for the serialized Question#data.
    #
    # @return [TrueClass] when the CSV row is valid and the underlying model is valid.
    # @return [FalseClass] when the CSV row is invalid and/or the underlying model is invalid.
    def valid?
      return false unless super
      return true if question.valid?
      # TODO: add errors from underlying question to the import
      false
    end

    def save!
      raise ActiveRecord::RecordInvalid, self unless valid?
      question.save!
    end

    def save
      valid? && question.save
    end

    def question
      return @question if defined?(@question)

      parent_question = questions[row['PART_OF']]&.question
      attributes = { text:, data:, subject_names:, keyword_names:, level: }
      if parent_question&.has_parts?
        attributes[:parent_question] = parent_question
        attributes[:child_of_aggregation] = true
      end
      @question = question_type.new(**attributes)
      parent_question.child_questions << @question if parent_question
      @question
    end
  end

  ##

  def self.build_row(row:, questions:)
    # In relying on inner classes, we need to specifically target the current class (a sub-class of
    # Question).  Oddly `self::ImportCsvRow` does not work.  We can use
    # `self.const_get(:ImportCsvRow)` but constantize is Rails idiomatic
    "#{name}::ImportCsvRow".constantize.new(row:, questions:, question_type: self)
  end

  ##
  # @see Question::ImporterCsv
  #
  # @param row [Enumerable] likely a row from {CSV.read}.
  # @param questions [Hash<#to_s,Question>] a hash of questions already processed from the
  #        originating CSV.  Useful for exposing a means of connecting relationships for a
  #        {Question::StimulusCaseStudy}
  # @return [Question] a subclass of {Question} derived from the row's TYPE property.
  # @return [Question::InvalidQuestion] when we have a row that doesn't have adequate information to
  #         build the proper {Question} subclass.
  # @return [#valid?, #save!, #errors] These three methods are the expected interface for what will
  #         be returned.
  def self.build_from_csv_row(row:, questions:)
    return Question::NoType.new(row) unless row['TYPE']

    klass = Question.type_name_to_class(row['TYPE'], fallback: nil)

    return Question::InvalidType.new(row) unless klass

    return Question::InvalidLevel.new(row) if row['LEVEL'] && Level.names.exclude?(row['LEVEL'])

    return Question::InvalidSubject.new(row) if extract_subject_names_from(row)&.any? { |subject| Subject.names.exclude?(subject.strip) }

    klass.build_row(row:, questions:)
  end

  ##
  # @param row [Enumerable] likely a row from {CSV.read}
  # @param required_headers [Array<String>] defaults to {.required_csv_headers}
  #
  # @return [NilClass] when the row has all the valid headers (e.g. column names for the CSV).
  # @return [Question::ExpectedColumnMissing] when the row is missing one or more expected headers.
  def self.invalid_question_due_to_missing_headers(row:, required_headers: required_csv_headers)
    expected = required_headers.sort
    overlap = (row.headers & expected).sort
    return nil if expected == overlap

    Question::ExpectedColumnMissing.new(expected: required_headers, given: row.headers)
  end

  FILTER_DEFAULT_SELECT = [:id, :level, :data, :text, :type, :keyword_names, :subject_names].freeze
  FILTER_DEFAULT_METHODS = [:type_label, :type_name, :data].freeze

  ##
  # @param select [Array<Symbol>] attribute names both passed forward to {.filter} and exposed in
  #        the resulting JSON object (in addition to those specified in :method).
  # @param methods [Array<Symbol>] attribute names to include in the JSON document.
  # @param kwargs [Hash<Symbol,Object>] values passed forward to {.filter}
  #
  # @note Why {.filter} and {.filter_as_json}?  There are two reasons: 1) we are interested in the
  #       STI field of :type and by default that is not something included in the base {#as_json}
  #       behavior; 2) we want to include keyword_names and subject_names.
  #
  #       The keyword_names and subject_names are constructed differently so as to minimize
  #       database queries.  I had tried to use keywords and subjects, but those are relations and
  #       behave a bit differently.  You'll want to look at the specs to see how this resolves.
  #
  # @return [Array<Hash>] A Ruby array of hashes where the hashes have the the keys specified in the
  #         :select parameter.
  #
  # @see .filter
  # rubocop:disable Metrics/MethodLength
  def self.filter_as_json(select: FILTER_DEFAULT_SELECT, methods: FILTER_DEFAULT_METHODS, search: false, **kwargs)
    ##
    # The :data method/field is an interesting creature; we want to "select" it in queries because
    # in most cases that is adequate.  Yet the {Question::StimulusCaseStudy#data} is unique, in that
    # it uses the {Question::StimulusCaseStudy#child_questions} to build the data.
    #
    # Hence we want to :select that data for querying, but rely instead on the :method.
    only = select - methods

    # Ensure 'data' is included in the select attributes
    only << :data unless only.include?(:data)

    # Ensure the `filter` method is called with eager loading for associations
    questions = filter(select: only, search:, **kwargs)

    # Convert to JSON and manually add image URLs and alt texts if they are included in the methods
    questions.map do |question|
      question_json = question.as_json(only:, methods:)

      if question.images.present?
        question_json['images'] = question.images_as_json
      else
        question_json['images'] = []
        question_json['alt_texts'] = []
      end

      question_json
    end
  end
  # rubocop:enable Metrics/MethodLength

  ##
  # @api private
  #
  # @param row [CsvRow]
  # @return [Array<String>]
  def self.extract_subject_names_from(row)
    extract_names_from(row, "SUBJECT")
  end

  ##
  # @api private
  #
  # @param row [CsvRow]
  # @return [Array<String>]
  def self.extract_keyword_names_from(row)
    extract_names_from(row, "KEYWORD")
  end

  def self.extract_names_from(row, column)
    row.flat_map do |header, value|
      next if value.blank?
      next unless header.present? && (header == "#{column}S" || header == column || header.start_with?("#{column}_"))
      value.split(/\s*,\s*/).map(&:strip)
    end.uniq.compact.sort
  end
  private_class_method :extract_names_from

  ##
  # This method ensures that we will consistently have a Question#keyword_names regardless of
  # whether the underlying query to reify the Question had a select statement that included the
  # "keyword_names" query field.
  #
  # @return [Array<String>]
  #
  # @see .filter_as_json
  # @see #find_or_create_subjects_and_keywords
  def keyword_names
    @keyword_names.presence || attributes.fetch(:keyword_names) { keywords.map(&:name) } || []
  end

  ##
  # @see #find_or_create_subjects_and_keywords
  attr_writer :keyword_names

  ##
  # This method ensures that we will consistently have a Question#subject_names regardless of
  # whether the underlying query to reify the Question had a select statement that included the
  # "subject_names" query field.
  #
  # @return [Array<String>]
  #
  # @see .filter_as_json
  # @see #find_or_create_subjects_and_keywords
  def subject_names
    @subject_names.presence || attributes.fetch(:subject_names) { subjects.map(&:name) } || []
  end
  ##
  # @see #find_or_create_subjects_and_keywords
  attr_writer :subject_names

  after_save :find_or_create_subjects_and_keywords

  ##
  # As part of the {.build_from_csv_row}, the subclasses are assigning the `@subject_names' and
  # `@keyword_names'.  When we save a record being imported, we want to persist those values to the
  # corresponding relationships (e.g. {#subjects} and {#keywords}).
  def find_or_create_subjects_and_keywords
    @subject_names&.each do |name|
      subjects << Subject.find_or_create_by(name:)
    end
    @subject_names = nil

    @keyword_names&.each do |name|
      keywords << Keyword.find_or_create_by(name:)
    end
    @keyword_names = nil
  end

  ##
  # Filter questions by keywords and/or subjects.
  #
  # We omit questions that are part of a {QuestionAggregation} (e.g. those that are children to a
  # {Question::StimulusCaseStudy}.
  #
  # @param keywords [Array<String>] when provided, a question must have all of the given keywords.
  # @param subjects [Array<String>] when provided, a question must have all of the provided
  #        subjects.
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
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/ParameterLists
  def self.filter(keywords: [], subjects: [], levels: [], bookmarked_question_ids: [], bookmarked: nil, type_name: nil, select: nil, user: nil, search: false)
    # By wrapping in an array we ensure that our keywords.size and subjects.size are counting
    # the number of keywords given and not the number of characters in a singular keyword that was
    # provided.
    keywords = Array.wrap(keywords)
    subjects = Array.wrap(subjects)
    levels = Array.wrap(levels)

    # Specifying a very arbitrary order
    questions = Question.includes(:keywords, :subjects, images: { file_attachment: :blob }).order(:id)
    questions = questions.search(search) if search.present?

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

    questions = questions.where(level: levels) if levels.present?

    questions = questions.where(child_of_aggregation: false)

    if keywords.present?
      keywords_subquery = Keyword.select(:question_id)
                                 .joins(:keywords_questions)
                                 .where(name: keywords)
                                 .group(:question_id)
      # We sanitize the subquery via Arel.  The above construction is adequate.
      questions = questions.where(Arel.sql("id IN (#{keywords_subquery.to_sql})"))
    end

    if subjects.present?
      subjects_subquery = Subject.select('question_id')
                                 .joins(:questions_subjects)
                                 .where(name: subjects)
                                 .group('question_id')
      # We sanitize the subquery via Arel.  The above construction is adequate.
      questions = questions.where(Arel.sql("id IN (#{subjects_subquery.to_sql})"))
    end

    questions = Question.where(id: bookmarked_question_ids) if bookmarked_question_ids.present?

    questions = user.bookmarked_questions if bookmarked

    return questions if select.blank?

    # The following for subject_names and keyword_names is to reduce the number of queries we send
    # to the database.  By favoring this mechanism we create the virtual attributes of
    # :subject_names and :keyword_names to each of the returned values.  Thus those values are
    # available in the JSON representation of each of these questions.
    #
    # We duplicate this as that results in an unfrozen array which we then proceed to modify.  We
    # need to modify this because the provided "subject_names" and "keyword_names" are not actual
    # fields but instead derived.
    select_statement = select.dup

    if select.include?(:subject_names)
      select_statement.delete(:subject_names)
      select_statement << %((SELECT ARRAY_AGG (subjects.name) AS kws
        FROM subjects
        INNER JOIN questions_subjects ON subjects.id = questions_subjects.subject_id
        INNER JOIN questions AS inner_q ON questions_subjects.question_id = questions.id
        WHERE inner_q.id = questions.id)
        AS "subject_names") # the virtual field "subject_names"
    end

    if select.include?(:keyword_names)
      select_statement.delete(:keyword_names)
      select_statement << %((SELECT ARRAY_AGG (keywords.name) AS kws
        FROM keywords
        INNER JOIN keywords_questions ON keywords.id = keywords_questions.keyword_id
        INNER JOIN questions AS inner_q ON keywords_questions.question_id = questions.id
        WHERE inner_q.id = questions.id)
        AS "keyword_names") # the virtual field "keyword_names"
    end

    questions.select(*select_statement)
  end

  private

  def index_searchable_field
    data_array = Array.wrap(data)

    joined_text = data_array.map do |data|
      sanitize_data_for_searchable_field(data)
    end.flatten.join(' ')

    self.searchable = final_scrub(joined_text)
  end

  def sanitize_data_for_searchable_field(data)
    data.values.flatten.map do |value|
      next unless value.is_a?(String) && !value.frozen?
      # add a space character so we can turn <p>Hello</p><p>there</p>
      # into 'Hello there' instead of 'Hellothere' after we strip tags
      v = value.gsub('>', '> ')
      ActionController::Base.helpers.strip_tags(v).squeeze(' ').strip
    end.compact
  end

  # Clean and normalize the text for PostgreSQL tsvector
  def final_scrub(text)
    text.gsub(/[^\w\s]/, ' ')
        .gsub(/\s+/, ' ')
        .strip
        .downcase
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/ParameterLists
end
# rubocop:enable Metrics/ClassLength
