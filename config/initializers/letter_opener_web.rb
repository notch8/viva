# frozen_string_literal: true

# Configure letter_opener_web to require admin authentication
# This allows authenticated admin clients to demo email functionality at /letter_opener
# NOTE: When deploying to real production, remove ENABLE_LETTER_OPENER env var
# to disable letter_opener_web entirely
if defined?(LetterOpenerWeb) && defined?(LetterOpenerWeb::LettersController)
  LetterOpenerWeb::LettersController.class_eval do
    before_action :authenticate_user!
    before_action :authenticate_admin!

    private

    def authenticate_admin!
      redirect_to root_path, alert: 'Access denied. Admin privileges required.' unless current_user&.admin?
    end
  end
end


