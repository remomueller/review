# frozen_string_literal: true

# Generic mailer setup
class ApplicationMailer < ActionMailer::Base
  default from: "#{ENV['website_name']} <#{ActionMailer::Base.smtp_settings[:email]}>"
  add_template_helper(EmailHelper)
  layout 'mailer'

  protected

  def setup_email
  #   attachments.inline['logo.png'] = File.read('app/assets/images/chat.png')
  # rescue
  #   nil
  end
end
