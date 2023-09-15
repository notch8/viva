# frozen_string_literal: true

##
# A matching {Question}'s data includes pairs (e.g. A goes to B, C goes to D).
#
# @see #well_formed_serialized_data
class Question::Matching < Question
  self.type_name = "Matching"

  def self.import_csv_row(row)
    text = row['TEXT']

    # Ensure that we have all of the candidate indices (the left and right side)
    indices = row.headers.each_with_object([]) do |header, array|
      next if header.blank?
      next unless header.start_with?("LEFT_", "RIGHT_")
      array << header.split(/_+/).last.to_i
    end.uniq.sort

    data = indices.map do |index|
      # It is okay that these will possibly be nil; because our downstream validation will catch
      # them.
      [row["LEFT_#{index}"], row["RIGHT_#{index}"]]
    end

    create!(text:, data:)
  end

  # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
  # for the data to be used in the application, beyond export of data, is minimal.
  serialize :data, JSON
  validate :well_formed_serialized_data
  validates :data, presence: true

  ##
  # Verify that the resulting data attribute is an array with each element being an array of two
  # strings.
  def well_formed_serialized_data
    unless data.is_a?(Array)
      errors.add(:data, "expected to be an array, got #{data.class.inspect}")
      return false
    end

    unless data.all? { |pair| pair.is_a?(Array) && pair.size == 2 && pair.all? { |d| d.is_a?(String) && d.present? } }
      errors.add(:data, "expected to be an array of arrays, each sub-array having two elements, both of which are strings")
      return false
    end

    true
  end
end
