class UserMailer < ActionMailer::Base
  default :from => ActionMailer::Base.smtp_settings[:user_name]
  
  def notify_system_admin(system_admin, user)
    setup_email
    @system_admin = system_admin
    @user = user
    mail(:to => system_admin.email,
         :subject => @subject + "#{user.name} Signed Up",
         :reply_to => user.email)
  end
  
  def publication_approval_reminder(publication, reviewer)
    setup_email
    @publication = publication
    @reviewer = reviewer
    mail(:to => reviewer.email,
         :subject => @subject + "New Publication Awaiting Approval: #{publication.abbreviated_title}",
         :reply_to => publication.user.email)
  end
  
  def status_activated(user)
    setup_email
    @user = user
    mail(:to => user.email,
         :subject => @subject + "#{user.name}'s Account Activated") #,
#         :reply_to => user.email)
  end
  
  protected
  
  def setup_email
    @subject = "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] "
  end
  
end
