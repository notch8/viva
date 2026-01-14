# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class AnalyticsReportService
  def initialize(report_type:, current_user:, start_date:, end_date:)
    @report_type = report_type
    @current_user = current_user
    @start_date = start_date
    @end_date = end_date
  end

  def generate_report
    method_name = "generate_#{report_type}_report"

    raise NoMethodError, "Report generator method '#{method_name}' not implemented" unless respond_to?(method_name, true) # true includes private methods
    send(method_name)
  end

  private

  attr_reader :report_type, :current_user, :start_date, :end_date

  def generate_user_report
    CSV.generate(headers: true) do |csv|
      csv << user_report_headers

      users.each do |user|
        csv << user_report_row(user)
      end
    end
  end

  def generate_assessment_report
    CSV.generate(headers: true) do |csv|
      csv << assessment_report_headers

      questions.each do |question|
        csv << assessment_report_row(question)
      end
    end
  end

  def generate_utilization_report
    CSV.generate(headers: true) do |csv|
      csv << utilization_report_headers

      utilization_data.each do |data|
        csv << utilization_report_row(data)
      end
    end
  end

  # User Report Methods
  def user_report_headers
    ['User Email', 'Date Created', 'Role', 'Last Login', 'Questions Created Count', 'Questions Exported Count']
  end

  def user_report_row(user)
    [
      user.email,
      user.created_at,
      user.role,
      user.last_sign_in_at,
      user.questions.count,
      user.questions_exported_count
    ]
  end

  def users
    base_scope = current_user.admin? ? User.all : User.where(id: current_user.id)

    if date_range_present?
      start_datetime = parse_date(start_date).beginning_of_day
      end_datetime = parse_date(end_date).end_of_day
      base_scope = base_scope.where(created_at: start_datetime..end_datetime)
    end

    base_scope.order(created_at: :desc)
  end

  # Assessment Report Methods
  def assessment_report_headers
    ['Assessment ID', 'Assessment Text', 'Created By', 'Date Created', 'Last Modified', 'Export Count', 'Resolved Feedback Count', 'Unresolved Feedback Count']
  end

  def assessment_report_row(question)
    [
      question.hashid,
      question.text,
      question.user.email,
      question.created_at,
      question.updated_at,
      question.exported_count,
      question.resolved_feedback_count,
      question.unresolved_feedback_count
    ]
  end

  def questions
    base_scope = current_user.admin? ? Question : current_user.questions

    if date_range_present?
      start_datetime = parse_date(start_date).beginning_of_day
      end_datetime = parse_date(end_date).end_of_day
      base_scope = base_scope.where(created_at: start_datetime..end_datetime)
    end

    base_scope.includes(:user).order(created_at: :desc)
  end

  # Utilization Report Methods
  def utilization_report_headers
    ['Question ID', 'Export Date', 'Export Type', 'Subject(s)']
  end

  def utilization_report_row(export_logger)
    # Manually fetch the question since there's no association
    question = Question.includes(:subjects).find_by(id: export_logger.question_id)

    [
      question&.hashid || 'N/A',
      export_logger.created_at.strftime('%Y-%m-%d %H:%M:%S'),
      export_logger.export_type,
      question_subjects(question)
    ]
  end

  def utilization_data
    base_scope = current_user.admin? ? ExportLogger : ExportLogger.where(user_id: current_user.id)

    if date_range_present?
      start_datetime = parse_date(start_date).beginning_of_day
      end_datetime = parse_date(end_date).end_of_day
      base_scope = base_scope.where(created_at: start_datetime..end_datetime)
    end

    # Use LEFT JOIN to include export logs even if question was deleted
    base_scope.joins("LEFT JOIN questions ON questions.id = export_loggers.question_id")
              .order(created_at: :desc)
  end

  def question_subjects(question)
    return '' unless question
    question.subjects.pluck(:name).join(', ')
  end

  # Helper Methods
  def date_range_present?
    start_date.present? && end_date.present?
  end

  def parse_date(date)
    case date
    when Date, DateTime
      date.to_date
    when String
      Date.parse(date)
    else
      date
    end
  end
end
# rubocop:enable Metrics/ClassLength
