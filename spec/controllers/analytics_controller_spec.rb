# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnalyticsController, type: :controller do
  describe '#export' do
    let(:user) { create(:user) }
    let(:csv_data) { "header1,header2\nvalue1,value2" }
    let(:report_service) { instance_double(AnalyticsReportService) }

    before do
      sign_in user
      allow(AnalyticsReportService).to receive(:new).and_return(report_service)
      allow(report_service).to receive(:generate_report).and_return(csv_data)
    end

    context 'with valid parameters' do
      it 'generates and sends a user report CSV' do
        post :export, params: {
          report_type: 'user',
          date_range: 'last_7_days'
        }

        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to include('attachment')
        expect(response.headers['Content-Disposition']).to include('user_report_last_7_days')
        expect(response.body).to eq(csv_data)
      end
    end

    context 'when report service raises an error' do
      before do
        allow(report_service).to receive(:generate_report).and_raise(StandardError, 'Report generation failed')
      end

      it 'allows the error to bubble up' do
        expect do
          post :export, params: {
            report_type: 'user',
            date_range: 'last_7_days'
          }
        end.to raise_error(StandardError, 'Report generation failed')
      end
    end

    context 'when not authenticated' do
      before { sign_out user }

      it 'redirects to login' do
        post :export, params: {
          report_type: 'user',
          date_range: 'last_7_days'
        }

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
