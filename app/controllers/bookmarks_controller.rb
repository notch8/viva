# frozen_string_literal: true
class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    @bookmark = current_user.bookmarks.find_or_create_by(question_id: params[:question_id])
    if @bookmark.save
      redirect_back(fallback_location: authenticated_root_path, notice: t('.success'))
    else
      redirect_back(fallback_location: authenticated_root_path, alert: t('.failure'))
    end
  end

  def destroy
    @bookmark = current_user.bookmarks.find_by(question_id: params[:id])
    if @bookmark&.destroy
      redirect_back(fallback_location: authenticated_root_path, notice: t('.success'))
    else
      redirect_back(fallback_location: authenticated_root_path, alert: t('.failure'))
    end
  end

  def destroy_all
    current_user.bookmarks.destroy_all if current_user.bookmarks.present?
    redirect_back(fallback_location: authenticated_root_path, notice: t('.success'))
  end

  def export
    @questions = current_user.bookmarked_questions

    case params[:format]
    when 'md'
      service = QuestionFormatter::MarkdownService
      export_file_for(service)
    when 'txt'
      send_data BookmarkExporter.as_text(@questions),
                filename: "bookmarked-questions-#{Time.zone.now.strftime('%Y%m%d')}.txt",
                type: 'text/plain'
    when 'md'
      send_data BookmarkExporter.as_markdown(@questions),
                filename: "bookmarked-questions-#{Time.zone.now.strftime('%Y%m%d')}.md",
                type: 'text/markdown'
    when 'xml', 'canvas'
      # Canvas uses QTI XML format
      xml_download
    when 'blackboard'
      # Blackboard uses TSV format
      send_data BookmarkExporter.as_blackboard(@questions),
                filename: "blackboard-questions-#{Time.zone.now.strftime('%Y%m%d')}.txt",
                type: 'text/tab-separated-values'
    when 'brightspace', 'moodle'
      # Not implemented yet - show a flash message and redirect
      redirect_back(fallback_location: authenticated_root_path,
                    alert: "#{format.capitalize} export is not implemented yet.")
    else
      redirect_back(fallback_location: authenticated_root_path, alert: t('.alert'))
    end
  end

  private

  def export_filename(now = Time.current)
    "questions-#{now.strftime('%Y-%m-%d_%H:%M:%S:%L')}"
  end

  def export_file_for(service)
    content = @questions.map { |question| service.new(question).format_content }.join('')
    send_data content, filename: "#{export_filename}.#{service.output_format}", type: 'text/plain'
  end

  def xml_download
    now = Time.current
    @title = "Viva Questions for #{now.strftime('%B %-d, %Y %9N')}"

    # Why the long suffix?  Because Canvas supports both "classic" and "new" format; and per
    # conversations with the client, we're looking to only export classic (as you can migrate a
    # classic question to new format).  This filename is another "helpful clue" and introduces
    # later considerations for what the file format might be.
    filename = "#{export_filename(now)}.classic-question-canvas.qti.xml"

    if any_question_has_images?
      serve_zip_file(filename)
    else
      serve_xml_file(filename)
    end
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
end
