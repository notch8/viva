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

    export_result(data: formatter_service.format_content)
  end

  private

  # rubocop:disable Metrics/MethodLength
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
    else
      raise "Format #{requested_format} is not yet supported for export"
    end
  end
  # rubocop:enable Metrics/MethodLength

  def file_name(suffix: formatter_service.output_format)
    "questions-#{requested_format}-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S:%L')}.#{suffix}"
  end

  def export_result(data:,
                    filename: file_name,
                    type: formatter_service.file_type,
                    is_file: formatter_service.is_file)
    { data:, filename:, type:, is_file: }
  end
end
