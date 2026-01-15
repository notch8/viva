# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnalyticsReportService do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:other_user) { create(:user) }

  let(:start_date) { Date.new(2026, 1, 1) }
  let(:end_date) { Date.new(2026, 1, 7) }

  describe '#generate_report' do
    describe 'user report' do
      let!(:old_user) { create(:user, created_at: 2.months.ago) }
      let!(:recent_user) { create(:user, created_at: 3.days.ago) }
      let!(:new_user) { create(:user, created_at: 1.day.ago) }

      before do
        # Create some questions for count testing
        create_list(:question_traditional, 2, user: recent_user)
        create_list(:question_traditional, 3, user: new_user)
      end

      context 'as admin user' do
        context 'with all data' do
          subject(:service) do
            described_class.new(
              report_type: 'user',
              current_user: admin_user,
              start_date: nil,
              end_date: nil
            )
          end

          it 'generates CSV with all users' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.headers).to eq(['User Email', 'Date Created', 'Role', 'Last Login',
                                          'Questions Created Count', 'Questions Exported Count'])
            # Should include all users including admin_user, regular_user, other_user
            expect(parsed.size).to eq(User.count)
            expect(parsed.pluck('User Email')).to include(
              old_user.email, recent_user.email, new_user.email, admin_user.email
            )
          end
        end

        context 'with date range' do
          # Create admin_user outside the date range to not affect the count
          let(:admin_user) { create(:user, :admin, created_at: 2.months.ago) }

          subject(:service) do
            described_class.new(
              report_type: 'user',
              current_user: admin_user,
              start_date: 5.days.ago.to_date,
              end_date: Time.zone.today
            )
          end

          it 'generates CSV with only users in date range' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.size).to eq(2) # recent_user and new_user
            emails = parsed.pluck('User Email')
            expect(emails).to include(recent_user.email, new_user.email)
            expect(emails).not_to include(old_user.email, admin_user.email)
          end
        end
      end

      context 'as regular user' do
        context 'with all data' do
          subject(:service) do
            described_class.new(
              report_type: 'user',
              current_user: regular_user,
              start_date: nil,
              end_date: nil
            )
          end

          it 'generates CSV with only current user' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.size).to eq(1)
            expect(parsed.first['User Email']).to eq(regular_user.email)
          end
        end

        context 'with date range' do
          let(:regular_user) { create(:user, created_at: 3.days.ago) }

          subject(:service) do
            described_class.new(
              report_type: 'user',
              current_user: regular_user,
              start_date: 5.days.ago.to_date,
              end_date: Time.zone.today
            )
          end

          it 'generates CSV with current user if in date range' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.size).to eq(1)
            expect(parsed.first['User Email']).to eq(regular_user.email)
          end
        end
      end
    end

    describe 'assessment report' do
      let!(:old_question) { create(:question_traditional, user: regular_user, created_at: 2.months.ago) }
      let!(:recent_question) { create(:question_traditional, user: regular_user, created_at: 3.days.ago) }
      let!(:other_user_question) { create(:question_traditional, user: other_user, created_at: 3.days.ago) }

      context 'as admin user' do
        context 'with all data' do
          subject(:service) do
            described_class.new(
              report_type: 'assessment',
              current_user: admin_user,
              start_date: nil,
              end_date: nil
            )
          end

          it 'generates CSV with all questions' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.headers).to eq(['Assessment ID', 'Assessment Text', 'Created By',
                                          'Date Created', 'Last Modified', 'Export Count',
                                          'Resolved Feedback Count', 'Unresolved Feedback Count'])
            expect(parsed.size).to eq(3)
            assessment_ids = parsed.pluck('Assessment ID')
            expect(assessment_ids).to include(
              old_question.hashid,
              recent_question.hashid,
              other_user_question.hashid
            )
          end
        end

        context 'with date range' do
          subject(:service) do
            described_class.new(
              report_type: 'assessment',
              current_user: admin_user,
              start_date: 5.days.ago.to_date,
              end_date: Time.zone.today
            )
          end

          it 'generates CSV with only questions in date range' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.size).to eq(2)
            assessment_ids = parsed.pluck('Assessment ID')
            expect(assessment_ids).to include(recent_question.hashid, other_user_question.hashid)
            expect(assessment_ids).not_to include(old_question.hashid)
          end
        end
      end

      context 'as regular user' do
        context 'with all data' do
          subject(:service) do
            described_class.new(
              report_type: 'assessment',
              current_user: regular_user,
              start_date: nil,
              end_date: nil
            )
          end

          it 'generates CSV with only user\'s questions' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.size).to eq(2)
            assessment_ids = parsed.pluck('Assessment ID')
            expect(assessment_ids).to include(old_question.hashid, recent_question.hashid)
            expect(assessment_ids).not_to include(other_user_question.hashid)
          end
        end

        context 'with date range' do
          subject(:service) do
            described_class.new(
              report_type: 'assessment',
              current_user: regular_user,
              start_date: 5.days.ago.to_date,
              end_date: Time.zone.today
            )
          end

          it 'generates CSV with only user\'s questions in date range' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.size).to eq(1)
            expect(parsed.first['Assessment ID']).to eq(recent_question.hashid)
          end
        end
      end
    end

    describe 'utilization report' do
      let!(:question_with_subject) { create(:question_traditional, user: regular_user) }
      let!(:subject1) { create(:subject, name: 'Math') }
      let!(:subject2) { create(:subject, name: 'Science') }

      let!(:old_export) do
        create(:export_logger,
               question_id: question_with_subject.id,
               user_id: regular_user.id,
               export_type: 'pdf',
               created_at: 2.months.ago)
      end

      let!(:recent_export) do
        create(:export_logger,
               question_id: question_with_subject.id,
               user_id: regular_user.id,
               export_type: 'csv',
               created_at: 3.days.ago)
      end

      let!(:other_user_export) do
        create(:export_logger,
               question_id: question_with_subject.id,
               user_id: other_user.id,
               export_type: 'json',
               created_at: 3.days.ago)
      end

      before do
        question_with_subject.subjects << [subject1, subject2]
      end

      context 'as admin user' do
        context 'with all data' do
          subject(:service) do
            described_class.new(
              report_type: 'utilization',
              current_user: admin_user,
              start_date: nil,
              end_date: nil
            )
          end

          it 'generates CSV with all export logs' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.headers).to eq(['Question ID', 'Export Date', 'Export Type', 'Subject(s)'])
            expect(parsed.size).to eq(3)
            export_types = parsed.pluck('Export Type')
            expect(export_types).to include('pdf', 'csv', 'json')
            expect(parsed.first['Subject(s)']).to eq('Math, Science')
          end
        end

        context 'with date range' do
          subject(:service) do
            described_class.new(
              report_type: 'utilization',
              current_user: admin_user,
              start_date: 5.days.ago.to_date,
              end_date: Time.zone.today
            )
          end

          it 'generates CSV with only export logs in date range' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.size).to eq(2)
            export_types = parsed.pluck('Export Type')
            expect(export_types).to include('csv', 'json')
            expect(export_types).not_to include('pdf')
          end
        end
      end

      context 'as regular user' do
        context 'with all data' do
          subject(:service) do
            described_class.new(
              report_type: 'utilization',
              current_user: regular_user,
              start_date: nil,
              end_date: nil
            )
          end

          it 'generates CSV with only user\'s export logs' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.size).to eq(2)
            export_types = parsed.pluck('Export Type')
            expect(export_types).to include('pdf', 'csv')
            expect(export_types).not_to include('json')
          end
        end

        context 'with date range' do
          subject(:service) do
            described_class.new(
              report_type: 'utilization',
              current_user: regular_user,
              start_date: 5.days.ago.to_date,
              end_date: Time.zone.today
            )
          end

          it 'generates CSV with only user\'s export logs in date range' do
            csv = service.generate_report
            parsed = CSV.parse(csv, headers: true)

            expect(parsed.size).to eq(1)
            expect(parsed.first['Export Type']).to eq('csv')
          end
        end
      end

      context 'with deleted question' do
        let!(:question_to_delete) { create(:question_traditional, user: admin_user) }
        let!(:deleted_question_export) do
          export_logger = create(:export_logger,
                                question_id: question_to_delete.id,
                                user_id: admin_user.id,
                                export_type: 'pdf',
                                created_at: 1.day.ago)

          # Delete the question after creating the export log
          # This should now work if you've removed the foreign key constraint
          # and just set question_id to NULL
          ExportLogger.where(question_id: question_to_delete.id)
                      .update(question_id: nil)
          question_to_delete.destroy

          export_logger.reload
        end

        subject(:service) do
          described_class.new(
            report_type: 'utilization',
            current_user: admin_user,
            start_date: nil,
            end_date: nil
          )
        end

        it 'includes export logs even for deleted questions' do
          csv = service.generate_report
          parsed = CSV.parse(csv, headers: true)

          # Find the row for the deleted question's export
          deleted_export_row = parsed.find { |row| row['Export Type'] == 'pdf' }

          expect(deleted_export_row).to be_present
          expect(deleted_export_row['Question ID']).to eq('N/A') # Should show N/A for deleted question
          expect(deleted_export_row['Subject(s)']).to eq('')  # No subjects since question is gone
        end
      end
    end

    describe 'invalid report type' do
      subject(:service) do
        described_class.new(
          report_type: 'invalid',
          current_user: admin_user,
          start_date: nil,
          end_date: nil
        )
      end

      it 'raises NoMethodError' do
        expect { service.generate_report }.to raise_error(
          NoMethodError,
          "Report generator method 'generate_invalid_report' not implemented"
        )
      end
    end
  end
end
