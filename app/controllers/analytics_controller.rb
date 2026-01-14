# frozen_string_literal: true
class AnalyticsController < ApplicationController
  def index
    render inertia: 'Analytics'
  end

  def export
    determine_dates

    report_service = AnalyticsReportService.new(
      report_type: params[:report_type],
      current_user: current_user,
      start_date: @start_date,
      end_date: @end_date
    )
    report = report_service.generate_report

    send_data report,
      filename: generate_filename(params[:report_type], params[:date_range]),
      type: 'text/csv',
      disposition: 'attachment'
  end

  private

  def generate_filename(report_type, date_range)
    "#{report_type}_report_#{date_range}_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
  end

  def determine_dates
    @start_date, @end_date =
      case params[:date_range]
      when 'custom'
        [Date.parse(params[:start_date]), Date.parse(params[:end_date])]
      when 'last_7_days'
        [7.days.ago.to_date, Date.today]
      when 'last_30_days'
        [30.days.ago.to_date, Date.today]
      when 'last_90_days'
        [90.days.ago.to_date, Date.today]
      when 'last_year'
        [1.year.ago.to_date, Date.today]
      else
        [nil, nil]
      end
  end
end
