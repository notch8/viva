# frozen_string_literal: true

require 'rexml/document'

##
# Service to handle formatting questions into Canvas's dti format
module QuestionFormatter
  class CanvasService < BaseService
    self.output_format = 'zip' # used as file suffix
    self.format = 'canvas' # used as format parameter
    self.file_type = 'application/zip'
    self.is_file = true

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
      zip_file_service = ZipFileService.new(images, xml_content, xml_filename, 'questions')
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
        build_manifest_structure(xml, files)
      end

      builder.to_xml
    end

    def build_manifest_structure(xml, files)
      xml.manifest(manifest_attributes) do
        build_metadata_section(xml)
        build_resources_section(xml, files)
      end
    end

    def manifest_attributes
      {
        'xmlns' => 'http://www.imsglobal.org/xsd/imsccv1p1/imscp_v1p1',
        'xmlns:lom' => 'http://ltsc.ieee.org/xsd/imsccv1p1/LOM/resource',
        'xmlns:imsmd' => 'http://www.imsglobal.org/xsd/imsmd_v1p2',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'identifier' => 'quiz-export',
        'xsi:schemaLocation' => 'http://www.imsglobal.org/xsd/imsccv1p1/imscp_v1p1 http://www.imsglobal.org/xsd/imscp_v1p1.xsd'
      }
    end

    def build_metadata_section(xml)
      xml.metadata do
        xml.schema 'IMS Content'
        xml.schemaversion '1.1.3'
      end
    end

    def build_resources_section(xml, files)
      xml.resources do
        add_quiz_resource(xml, files)
        add_image_resources(xml, files)
      end
    end

    def add_quiz_resource(xml, files)
      quiz_file = files.find { |file| file.end_with?('questions.xml') }
      return unless quiz_file
      xml.resource('identifier' => 'quiz-resource', 'type' => 'imsqti_xmlv1p2') do
        xml.file('href' => quiz_file)
      end
    end

    def add_image_resources(xml, files)
      image_files = files.select { |file| file.include?('/images/') }
      image_files.each do |file|
        image_name = File.basename(file, File.extname(file))
        xml.resource('identifier' => "media-#{image_name}", 'type' => 'webcontent') do
          xml.file('href' => file)
        end
      end
    end
  end
end
