# frozen_string_literal: true

##
# Service to handle the export process for bookmarks
#
# This service is responsible for:
# - Determining the appropriate file format and structure for exports
# - Creating the appropriate response data structure (file vs content)
# - Setting correct content types and filenames
# - Handling zip file creation when necessary
#
# @see BookmarkExporter for the actual content formatting logic
class BookmarkExportService
  attr_reader :questions, :bookmarks

  def initialize(bookmarks)
    @bookmarks = bookmarks
    @questions = bookmarks.map(&:question)
  end

  def export(format)
    case format
    when 'canvas'
      canvas_export
    when 'blackboard'
      blackboard_export
    when 'brightspace'
      brightspace_export
    when 'moodle_xml'
      moodle_export
    when 'txt'
      text_export
    when 'md'
      markdown_export
    when 'xml'
      xml_export
    end
  end

  private

  def canvas_export
    canvas_result = BookmarkExporter.as_canvas(questions)

    # Check if the result is a temp file (for zip) or XML string
    if canvas_result.is_a?(Tempfile)
      # It's a zip file (temp file)
      filename = "questions-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S:%L')}.classic-question-canvas.qti.zip"
      { data: canvas_result,
        filename:,
        type: "application/zip",
        is_file: true } # Add a flag to indicate this is a file path
    else
      # It's XML content (string)
      filename = "questions-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S:%L')}.classic-question-canvas.qti.xml"
      { data: canvas_result,
        filename:,
        type: "application/xml" }
    end
  end

  def blackboard_export
    { data: BookmarkExporter.as_blackboard(questions),
      filename: "blackboard_export.txt",
      type: "text/plain" }
  end

  def brightspace_export
    { data: BookmarkExporter.as_brightspace(questions),
      filename: "brightspace_export.txt",
      type: "text/plain" }
  end

  def moodle_export
    { data: BookmarkExporter.as_moodle(questions),
      filename: "moodle_export.xml",
      type: "application/xml" }
  end

  def text_export
    { data: BookmarkExporter.as_text(questions),
      filename: "questions-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S:%L')}.txt",
      type: "text/plain",
      is_file: false }
  end

  def markdown_export
    { data: BookmarkExporter.as_markdown(questions),
      filename: "questions-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S:%L')}.md",
      type: "text/plain",
      is_file: false }
  end

  def xml_export
    xml_content = BookmarkExporter.as_xml(questions)

    # Check if any questions have images
    if questions.any? { |question| question.images.any? }
      # If there are images, we need to create a zip file
      xml_filename = "questions-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S:%L')}.xml"
      images = questions.flat_map(&:images)

      # Use ZipFileService to create the zip file
      zip_file_service = ZipFileService.new(images, xml_content, xml_filename)
      temp_file = zip_file_service.generate_zip

      { data: temp_file,
        filename: "questions-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S:%L')}.zip",
        type: "application/zip",
        is_file: true }
    else
      # If no images, just return the XML content
      { data: xml_content,
        filename: "questions-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S:%L')}.xml",
        type: "application/xml; charset=utf-8",
        is_file: false }
    end
  end
end
