# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  def index
    # This is a bit different than you might be used to. Ideally, we'd have respond_to behavior.
    #
    # However, Inertia behaves differently. So we have format sniffing instead of the conventional:
    #
    #   respond_to do |wants|
    #     wants.xml { }
    #     wants.inertia { }
    #   end
    #
    # Why? Because Inertia is not registered as a mime-type.
    if request.format.xml?
      now = Time.current
      @title = "Viva Questions for #{now.strftime('%B %-d, %Y %9N')}"

      # Why the long suffix? Because Canvas supports both "classic" and "new" format; and per
      # conversations with the client, we're looking to only export classic (as you can migrate a
      # classic question to new format). This filename is another "helpful clue" and introduces
      # later considerations for what the file format might be.
      filename = "questions-#{now.strftime('%Y-%m-%d_%H:%M:%S:%L')}.classic-question-canvas.qti.xml"
      @questions = search_questions

      if any_question_has_images?
        serve_zip_file(filename)
      else
        serve_xml_file(filename)
      end
    else
      render inertia: 'Search', props: shared_props
    end
  end

  def search_questions
    if params[:search].present?
      query = sanitize_search_query(params[:search])
      raw_query = params[:search].downcase
      
      base_query = Question
        .includes(:keywords, :subjects, :images)
        .select("questions.*, 
                CASE 
                  WHEN LOWER(text) LIKE '%#{raw_query}%' THEN 2
                  WHEN LOWER(data) LIKE '%#{raw_query}%' THEN 1
                  ELSE 0 
                END + 
                ts_rank_cd(tsv, to_tsquery('english', '#{query}')) AS rank")
        .where("tsv @@ to_tsquery('english', ?) OR LOWER(text) LIKE ? OR LOWER(data) LIKE ?", 
               query, "%#{raw_query}%", "%#{raw_query}%")
      
      base_query = apply_filters(base_query)
      base_query.order("rank DESC")
    else
      base_query = Question.includes(:keywords, :subjects, :images)
      apply_filters(base_query)
    end
  end
  
  private

  def any_question_has_images?
    @questions.any? { |question| question.images.any? }
  end

  def serve_zip_file(xml_filename)
    xml_content = render_to_string(format: :xml)
    images = @questions.flat_map(&:images)
    zip_file_service = ZipFileService.new(images, xml_content, xml_filename)
    temp_file = zip_file_service.generate_zip
    zip_filename = xml_filename.gsub('.xml', '.zip')

    send_file(temp_file.path, filename: zip_filename)
  end

  def serve_xml_file(filename)
    # Set the 'Content-Disposition' as 'attachment' so that instead of showing the XML file in the
    # browser, we instead tell the browser to automatically download this file.
    response.headers['Content-Disposition'] = %(attachment; filename="#{filename}")
    render format: :xml
  end

  def sanitize_search_query(input)
    input
      .split
      .map { |term| term.gsub(/['?\\:()!&|]/, '') } # Remove invalid characters
      .map { |term| "#{term}:*" }                   # Add wildcard for partial matching
      .join(" & ")                                  # Join terms with AND operator
  end

  # rubocop:disable Metrics/MethodLength
  def shared_props
    {
      keywords: Keyword.names,
      subjects: Subject.names,
      types: Question.type_names,
      type_names: Question.type_names,
      levels: Level.names,
      selectedKeywords: params[:selected_keywords],
      selectedSubjects: params[:selected_subjects],
      selectedTypes: params[:selected_types],
      selectedLevels: params[:selected_levels],
      searchTerm: params[:search],
      filteredQuestions: search_questions.map { |q| 
        {
          id: q.id,
          text: q.text,
          type_name: q.type_name,
          data: q.data,
          type: q.model_name.name,
          type_label: q.type_label,
          level: q.level,
          keyword_names: q.keyword_names.sort,
          subject_names: q.subject_names,
          alt_texts: [],
          images: q.images.map { |img| 
            {
              id: img.id,
              url: img.url,
              alt_text: img.alt_text
            }
          }
        }
      },
      exportHrefs: export_hrefs,
      bookmarkedQuestionIds: current_user.bookmarks.pluck(:question_id),
      activeFilters: {
        search: params[:search],
        keywords: params[:selected_keywords],
        subjects: params[:selected_subjects],
        types: params[:selected_types],
        levels: params[:selected_levels]
      }
    }
  end
  # rubocop:enable Metrics/MethodLength

  ##
  # @return [Array<Hash<Symbol,String>] the types of exports supported by the {SearchController}.
  def export_hrefs
    [{ type: "xml", href: ".xml#{request.original_fullpath.slice(1..-1)}" }]
  end

  def create_new_export
    # Add logic to create an export with the provided filtered questions here once the export model & functionality are created.
    # Export.create(filtered_questions)... etc
  end

  def filter_values
    {
      keywords: params[:selected_keywords],
      subjects: params[:selected_subjects],
      type_name: params[:selected_types],
      level: params[:selected_levels],
      bookmarked_question_ids: params[:bookmarked_question_ids],
      bookmarked: ActiveModel::Type::Boolean.new.cast(params[:bookmarked])
    }.compact.reject { |k, v| v.nil? || v.empty? }
  end

  def apply_filters(query)
    if params[:selected_levels].present?
      query = query.where(level: params[:selected_levels])
    end
    if params[:selected_keywords].present?
      query = query.joins(:keywords).where(keywords: { name: params[:selected_keywords] })
    end
    if params[:selected_subjects].present?
      query = query.joins(:subjects).where(subjects: { name: params[:selected_subjects] })
    end
    if params[:selected_types].present?
      types = Array(params[:selected_types]).map do |type|
        case type
        when "Multiple Choice"
          "Question::Traditional"
        when "Select All That Apply"
          "Question::SelectAllThatApply"
        when "Stimulus Case Study"
          "Question::StimulusCaseStudy"
        when "Matching"
          "Question::Matching"
        when "Essay"
          "Question::Essay"
        when "Drag and Drop"
          "Question::DragAndDrop"
        when "Categorization"
          "Question::Categorization"
        when "Bow Tie"
          "Question::BowTie"
        when "Upload"
          "Question::Upload"
        else
          type
        end
      end
      query = query.where(type: types)
    end
    query.distinct
  end
end
