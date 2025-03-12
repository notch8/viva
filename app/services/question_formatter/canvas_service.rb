# frozen_string_literal: true

require 'rexml/document'

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

      xml_content = pretty_xml!(xml_content)

      xml_filename = 'questions.xml'
      images = questions.flat_map(&:images)

      # Use ZipFileService to create the zip file
      zip_file_service = ZipFileService.new(images, xml_content, xml_filename)
      temp_file = zip_file_service.generate_zip
      add_manifest!(temp_file)
      # Return the temp file object (not just the data)
      temp_file
    end

    private

    # Returns a pretty version of the xml input
    def pretty_xml!(xml_content)
      String.new.tap do |output|
        REXML::Formatters::Pretty.new.tap do |formatter|
          formatter.compact = true
          formatter.width = Float::INFINITY
          formatter.write(REXML::Document.new(xml_content), output)
        end
      end
    end

    def add_manifest!(zip_file)
      Zip::File.open(zip_file.path, Zip::File::CREATE) do |zip_entries|
        files = zip_entries.map(&:name)
        manifest = generate_manifest(files)
        zip_entries.get_output_stream('imsmanifest.xml') do |os|
          os.write(manifest)
        end
      end
    end

    def generate_manifest(files)
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.manifest do
          xml.resources do
            files.each do |file|
              xml.resource do
                xml.file href: file
              end
            end
          end
        end
      end

      builder.to_xml
    end
  end
end
