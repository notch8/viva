# frozen_string_literal: true

##
# Service to handle the export process for bookmarks
#
# This service is responsible for:
# - Determining the appropriate file format and structure for exports
# - Creating the appropriate response data structure (file vs content)
# - Setting correct content types and filenames
# - Handling zip file creation when necessary
class BookmarkExportService
  attr_reader :bookmarks, :questions
  attr_accessor :formatter_service, :requested_format

  # Initialize a new export service
  #
  # @param bookmarks [Array<Bookmark>] The bookmarks to be exported
  # @return [BookmarkExportService] A new instance of the service
  def initialize(bookmarks)
    @bookmarks = bookmarks
    @questions = bookmarks.map(&:question)
  end

  # Export bookmarks in the specified format
  #
  # @param requested_format [String] The LMS format to export ('txt', 'md', 'canvas', etc.)
  # @return [Hash, nil] A hash containing the export data, filename, content type, and file flag
  def export(requested_format)
    @requested_format = requested_format
    @formatter_service = formatter_service_for(requested_format).new(questions)

    export_content = formatter_service.format_content
    export_method = "#{requested_format}_export"

    if respond_to?(export_method, true)
      send(export_method, export_content)
    else
      "Format #{requested_format} is not yet supported for export"
    end
  end

  private

  def formatter_service_for(requested_format)
    case requested_format
    when 'txt'
      QuestionFormatter::PlainTextService
    when 'md'
      QuestionFormatter::MarkdownService
    when 'canvas'
      QuestionFormatter::CanvasService
    when 'blackboard'
      QuestionFormatter::BlackboardService
    when 'd2l'
      QuestionFormatter::D2lService
    when 'moodle'
      QuestionFormatter::MoodleService
    end
  end

  def file_name(suffix: formatter_service.output_format)
    "questions-#{requested_format}-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S:%L')}.#{suffix}"
  end

  def export_result(data:,
                    filename: file_name,
                    type: formatter_service.file_type,
                    is_file: false)
    { data:, filename:, type:, is_file: }
  end

  # Export bookmarks in Canvas QTI format
  #
  # @return [Hash] A hash containing the export data, filename, content type, and file flag
  def canvas_export(data)
    data.is_a?(Tempfile) ? canvas_zip_export(data) : canvas_xml_export(data)
  end

  # Create export hash for Canvas zip file
  #
  # @param temp_file [Tempfile] The zip file containing Canvas export
  # @return [Hash] A hash containing the export data, filename, content type, and file flag
  def canvas_zip_export(data)
    export_result(data:,
                  filename: file_name(suffix: 'zip'),
                  type: 'application/zip',
                  is_file: true)
  end

  # Create export hash for Canvas XML content
  #
  # @param xml_content [String] The XML content for Canvas export
  # @return [Hash] A hash containing the export data, filename, content type, and file flag
  def canvas_xml_export(data)
    export_result(data:)
  end

  # Export bookmarks in Blackboard format
  #
  # @return [Hash] A hash containing the export data, filename, and content type
  def blackboard_export(data)
    export_result(data:)
  end

  # Export bookmarks in Brightspace/D2L format
  #
  # @return [Hash] A hash containing the export data, filename, and content type
  def d2l_export(data)
    export_result(data:, is_file: true)
  end

  # Export bookmarks in Moodle XML format
  #
  # @return [Hash] A hash containing the export data, filename, and content type
  def moodle_export(data)
    export_result(data:)
  end

  # Export bookmarks as plain text
  #
  # @return [Hash] A hash containing the export data, filename, content type, and file flag
  def txt_export(data)
    export_result(data:)
  end

  # Export bookmarks as markdown
  #
  # @return [Hash] A hash containing the export data, filename, content type, and file flag
  def md_export(data)
    export_result(data:)
  end
end
