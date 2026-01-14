module Reports
  class UserReportService

    def initialize(user)
      @user = user
    end

    def generate_report
      CSV.generate(headers: true) do |csv|
        csv << ['User Email', 'Date Created', 'Role', 'Last Login', 'Questions Created Count', 'Questions Exported Count']

        users.each do |user|
          csv << [user.email, user.created_at, user.role, user.last_sign_in_at, user.questions.count, user.questions_exported_count]
        end
      end
    end
    
    private
    attr_reader :user

    def users
      user.admin? ? User.all : [user]
    end
  end
end