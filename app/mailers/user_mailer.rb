class UserMailer < ActionMailer::Base
  default :from => ActionMailer::Base.smtp_settings[:user_name]
  
  def notify_system_admin(system_admin, user)
    @system_admin = system_admin
    @user = user
    mail(:to => system_admin.email,
         :subject => "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] #{user.name} Signed Up",
         :reply_to => user.email)
  end
end
