# frozen_string_literal: true
class AnalyticsController < ApplicationController
  def index
    render inertia: 'Analytics'
  end

  def export
    report_service = Reports::UserReportService.new(current_user)
    report = report_service.generate_report
    send_data report,
      filename: 'user_report.csv',
      type: 'text/csv',
      disposition: 'attachment'
  end
end
