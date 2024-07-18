# frozen_string_literal: true
require 'zip'

class ZipFileService
  def initialize(images, xml_content, filename)
    @images = images
    @xml_content = xml_content
    @filename = filename
  end

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

  def add_image_to_zip(zipfile, image, id)
    image_filename = image.file.filename.to_s
    image_binary = image.file.download

    zipfile.get_output_stream("images/#{id}/#{image_filename}") do |f|
      f.write(image_binary)
    end
  end
end
