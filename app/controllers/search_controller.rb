# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  def index
    # This is a bit different than you might be used to.  Ideally we'd have respond_to behavior.
    #
    # However, inertia behaves differently.  So we have format sniffing instead of the conventional:
    #
    #   respond_to do |wants|
    #     wants.xml { }
    #     wants.inertia { }
    #   end
    #
    # Why? Because inertia is not registered as a mime-type
    if request.format.xml?
      now = Time.current
      @title = "Viva Questions for #{now.strftime('%B %-d, %Y %9N')}"

      # Why the long suffix?  Because Canvas supports both "classic" and "new" format; and per
      # conversations with the client, we're looking to only export classic (as you can migrate a
      # classic question to new format).  This filename is another "helpful clue" and introduces
      # later considerations for what the file format might be.
      filename = "#{export_filename(now)}.classic-question-canvas.qti.xml"
      @questions = Question.filter(**filter_values)

      if any_question_has_images?
        serve_zip_file(filename)
      else
        serve_xml_file(filename)
      end
    else
      render inertia: 'Search', props: shared_props
    end
  end

  # download bookmarked questions
  def download
    @questions = Question.where(id: Bookmark.select(:question_id))
    case params[:format]
    when 'md'
      md_download
    when 'txt'
      text_download
    else
      redirect_to authenticated_root_path, alert: t('.alert')
    end
  end

  private

  def export_filename(now = Time.current)
    "questions-#{now.strftime('%Y-%m-%d_%H:%M:%S:%L')}"
  end

  def text_download
    content = @questions.map { |question| QuestionFormatter::PlainTextService.new(question).format_content }.join('')
    send_data content, filename: "#{export_filename}.txt", type: 'text/plain'
  end

  def md_download
    content = @questions.map { |question| QuestionFormatter::MarkdownService.new(question).format_content }.join('')
    send_data content, filename: "#{export_filename}.md", type: 'text/plain'
  end

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

  # rubocop:disable Metrics/MethodLength
  def shared_props
    {
      keywords: Keyword.names,
      subjects: Subject.names,
      types: Question.type_names, # Deprecated Favor :type_names
      type_names: Question.type_names,
      levels: Level.names,
      selectedKeywords: params[:selected_keywords],
      selectedSubjects: params[:selected_subjects],
      selectedTypes: params[:selected_types],
      selectedLevels: params[:selected_levels],
      filteredQuestions: Question.filter_as_json(search: params[:search], **filter_values),
      exportHrefs: export_hrefs,
      bookmarkedQuestionIds: current_user.bookmarks.pluck(:question_id)
    }
  end
  # rubocop:enable Metrics/MethodLength

  ##
  # @return [Array<Hash<Symbol,String>] the types of exports supported by the {SearchController}.
  def export_hrefs
    [{ type: "xml", href: ".xml#{request.original_fullpath.slice(1..-1)}" }]
  end

  def create_new_export
    # add logic to create an export with the provided filtered questions here once the export model & functionality are created.
    # Export.create(filtered_questions)... etc
  end

  def filter_values
    {
      keywords: params[:selected_keywords],
      subjects: params[:selected_subjects],
      type_name: params[:selected_types],
      levels: params[:selected_levels],
      bookmarked_question_ids: params[:bookmarked_question_ids],
      bookmarked: ActiveModel::Type::Boolean.new.cast(params[:bookmarked]),
      user: current_user
    }
  end
end
