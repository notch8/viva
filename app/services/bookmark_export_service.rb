# frozen_string_literal: true

##
# Service to handle exporting bookmarks in various formats
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
      filename: "bookmarks.txt",
      type: "text/plain" }
  end

  def markdown_export
    { data: BookmarkExporter.as_markdown(questions),
      filename: "bookmarks.md",
      type: "text/plain" }
  end
end
