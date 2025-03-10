# frozen_string_literal: true

##
# Service to handle formatting questions into Canvas's dti format
module QuestionFormatter
  class CanvasService < BaseService
    self.output_format = 'xml' # used as file suffix
    self.format = 'canvas' # used as format parameter
    self.file_type = 'application/xml'

    def format_content
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
  end
end
