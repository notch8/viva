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
class BookmarkExporter
  def self.as_text(questions)
    questions.map { |question| QuestionFormatter::PlainTextService.new(question).format_content }.join("\n\n")
  end

  def self.as_markdown(questions)
    questions.map { |question| QuestionFormatter::MarkdownService.new(question).format_content }.join("\n\n")
  end

  def self.as_xml(questions)
    # Use the existing XML export functionality
    xml_content = ApplicationController.render(
      template: 'bookmarks/export',
      layout: false,
      assigns: { questions:, title: "Viva Questions Export #{Time.current.strftime('%B %-d, %Y')}" }
    )
    xml_content
  end

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

  def self.as_blackboard(questions)
    # Blackboard uses TSV format
    questions.map { |question| QuestionFormatter::BlackboardService.new(question).format_content }.join("\n\n")
  end

  def self.as_brightspace(_questions)
    # Not implemented yet
    "BrightSpace export format is not implemented yet."
  end

  def self.as_moodle(questions)
    # Moodle uses its own XML format, which is implemented in MoodleService
    QuestionFormatter::MoodleService.new(questions).format_content
  end

  def self.generate_zip_file(questions, format)
    xml_filename = "questions-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S:%L')}.#{format}.xml"
    xml_content = generate_content_for_format(questions, format)

    # Get all images from questions
    images = questions.flat_map(&:images)

    # Create zip file
    zip_file_service = ZipFileService.new(images, xml_content, xml_filename)
    zip_file_service.generate_zip
  end

  def self.generate_content_for_format(questions, format)
    case format
    when 'canvas'
      ApplicationController.render(
        template: 'bookmarks/export',
        layout: false,
        assigns: { questions:, title: "Canvas Export #{Time.current.strftime('%B %-d, %Y')}" }
      )
    when 'blackboard'
      # Use Blackboard specific formatter if available
      questions.map { |question| QuestionFormatter::BlackboardService.new(question).format_content }.join("\n\n")
    when 'brightspace'
      # Use BrightSpace specific formatter if available
      "BrightSpace export format is not implemented yet."
    when 'moodle'
      # Use Moodle specific formatter
      QuestionFormatter::MoodleService.new(questions).format_content
    end
  end

  def to_moodle_xml
    # Generate Moodle-specific XML format
    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      @bookmarks.each do |bookmark|
        question = bookmark.question
        # Call the appropriate exporter method for each question type
        question.to_moodle_xml(xml) if question.respond_to?(:to_moodle_xml)
      end
    end

    builder.to_xml
  end
end
