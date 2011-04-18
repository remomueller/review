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
  
  def publication_approval(publication, pp_committee)
    setup_email
    @publication = publication
    @user = publication.user
    @approval_status = ''
    if @publication.status == 'approved'
      @approval_status = 'approved by the P&P Committee'
    elsif @publication.status == 'nominated'
      @approval_status = 'approved by the Steering Committee'
    elsif @publication.status == 'not approved' and pp_committee
      @approval_status = 'denied by the P&P Committee'
    elsif @publication.status == 'not approved' and not pp_committee
      @approval_status = 'denied by the Steering Committee'
    end
    mail(:to => @user.email,
         :subject => @subject + "Publication Proposal for #{@publication.abbreviated_title} has been #{@approval_status}")
  end
  
  protected
  
  def setup_email
    @subject = "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] "
  end
  
end
