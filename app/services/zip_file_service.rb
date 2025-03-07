# frozen_string_literal: true
require 'zip'

##
# Service to create zip files containing XML content and images
#
# This service is responsible for:
# - Creating temporary zip files
# - Adding XML content to the zip file
# - Adding images to the zip file with appropriate directory structure
class ZipFileService
  # Initialize a new zip file service
  #
  # @param images [Array<Image>] The images to include in the zip file
  # @param xml_content [String] The XML content to include in the zip file
  # @param filename [String] The name of the XML file within the zip
  # @return [ZipFileService] A new instance of the service
  def initialize(images, xml_content, filename)
    @images = images
    @xml_content = xml_content
    @filename = filename
  end

  # Generate a zip file containing the XML content and images
  #
  # @return [Tempfile] A temporary zip file
  def generate_zip
    temp_file = Tempfile.new(["questions-", ".zip"])

    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream(@filename) { |f| f.write(@xml_content) }

      @images.each do |image|
        add_image_to_zip(zipfile, image, image.question_id)
      end
    end

    temp_file
  end

  private

  # Add an image to the zip file
  #
  # @param zipfile [Zip::File] The zip file to add the image to
  # @param image [Image] The image to add
  # @param id [Integer] The question ID for directory organization
  # @return [void]
  def add_image_to_zip(zipfile, image, id)
    image_filename = image.file.filename.to_s
    image_binary = image.file.download

    zipfile.get_output_stream("images/#{id}/#{image_filename}") do |f|
      f.write(image_binary)
    end
  end
end
