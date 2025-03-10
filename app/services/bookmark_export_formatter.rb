# frozen_string_literal: true

##
# Service to handle the content formatting for bookmark exports
#
# This service is responsible for:
# - Formatting question content into various export formats (text, markdown, XML, etc.)
# - Implementing the specific requirements of each export format
# - Converting question data into the appropriate structure for each format
#
# @see BookmarkExportService for the export process handling
class BookmarkExportFormatter
  def initialize(service, questions, format)
    @questions = questions
    @format = format
    @service = service 
  end

  def export(questions, format)
    method = "as_#{format}"
    raise "Format #{format} is not yet supported for export" unless respond_to?(method)

    send(method, questions)
  end

  private

  # Format questions as plain text
  #
  # @param questions [Array<Question>] The questions to format
  # @return [String] The formatted text content
  def self.as_text(questions)
    questions.map { |question| QuestionFormatter::PlainTextService.new(question).format_content }.join("\n\n")
  end

  # Format questions as markdown
  #
  # @param questions [Array<Question>] The questions to format
  # @return [String] The formatted markdown content
  def self.as_md(questions)
    questions.map { |question| QuestionFormatter::MarkdownService.new(question).format_content }.join("\n\n")
  end

  # Format questions for Canvas LMS
  # If questions have images, creates a zip file
  #
  # @param questions [Array<Question>] The questions to format
  # @return [String, Tempfile] The formatted XML content or a zip file
  def self.as_canvas(questions)
    # Canvas uses the QTI XML format
    # Generate the XML content
    xml_content = ApplicationController.render(
      template: 'bookmarks/export',
      layout: false,
      assigns: { questions:, title: "Canvas Export #{Time.current.strftime('%B %-d, %Y')}" }
    )

    # Check if any questions have images
    if questions.any? { |question| question.images.any? }
      # If there are images, we need to create a zip file
      xml_filename = "questions-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S:%L')}.classic-question-canvas.qti.xml"
      images = questions.flat_map(&:images)

      # Use ZipFileService to create the zip file
      zip_file_service = ZipFileService.new(images, xml_content, xml_filename)
      temp_file = zip_file_service.generate_zip

      # Return the temp file object (not just the data)
      temp_file
    else
      # If no images, just return the XML content
      xml_content
    end
  end

  # Format questions for Blackboard LMS
  #
  # @param questions [Array<Question>] The questions to format
  # @return [String] The formatted content for Blackboard
  def self.as_blackboard(questions)
    # Blackboard uses TSV format
    questions.map { |question| QuestionFormatter::BlackboardService.new(question).format_content }.join("\n\n")
  end

  # Format questions for Brightspace D2L LMS
  #
  # @param _questions [Array<Question>] The questions to format
  # @return [String] the formatted content for Brightspace
  def self.as_d2l(questions)
    # Blackboard uses CSV format
    QuestionFormatter::D2lService.new(questions).format_content
  end

  # Format questions for Moodle LMS
  #
  # @param questions [Array<Question>] The questions to format
  # @return [String] The formatted XML content for Moodle
  def self.as_moodle(questions)
    # Moodle uses its own XML format, which is implemented in MoodleService
    QuestionFormatter::MoodleService.new(questions).format_content
  end
end
