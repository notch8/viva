# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base # rubocop:disable Style/Documentation
  default from: ENV.fetch('MAILER_FROM', 'no-reply@notch8.cloud')
  layout 'mailer'
end
