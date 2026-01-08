# frozen_string_literal: true

##
# Error message that is returned when the SUBJECT given is unexpected.
#
class Question::InvalidSubject < Question::InvalidQuestion
  def message
    subjects = format_terms_for_message(extract_names_from(row).map(&:strip))
    "row had SUBJECT of #{subjects} but expected only to include the following: #{Subject.names.map { |name| name }.join(', ')}"
  end

  def extract_names_from(row, column: 'SUBJECT')
    row.flat_map do |header, value|
      next if value.blank?
      next unless header.present? && (header == "#{column}S" || header == column || header.start_with?("#{column}_"))
      value.split(/\s*,\s*/).map(&:strip)
    end.uniq.compact.sort
  end

  def format_terms_for_message(terms)
    case terms.size
    when 0
      ''
    when 1
      terms.first
    when 2
      terms.join(' and ')
    else
      "#{terms[0...-1].join(', ')}, and #{terms.last}"
    end
  end
end
