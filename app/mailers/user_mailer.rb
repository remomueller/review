class UserMailer < ActionMailer::Base
  default :from => ActionMailer::Base.smtp_settings[:user_name]
  
  def notify_system_admin(system_admin, user)
    @system_admin = system_admin
    @user = user
    mail(:to => system_admin.email,
         :subject => "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] #{user.name} Signed Up",
         :reply_to => user.email)
  end
  
  def publication_approval_reminder(publication, reviewer)
    @publication = publication
    @reviewer = reviewer
    mail(:to => reviewer.email,
         :subject => "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] New Publication Awaiting Approval: #{publication.abbreviated_title}",
         :reply_to => publication.user.email)
  end
end
