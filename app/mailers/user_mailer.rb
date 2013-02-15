class UserMailer < ActionMailer::Base
  default from: "#{DEFAULT_APP_NAME} <#{ActionMailer::Base.smtp_settings[:email]}>"

  def notify_system_admin(system_admin, user)
    setup_email
    @system_admin = system_admin
    @user = user
    mail(to: system_admin.email,
         subject: "#{user.name} Signed Up",
         reply_to: user.email)
  end

  def publication_approval_reminder(current_user, to, cc, subject, body)
    mail(to: to, cc: cc, reply_to: current_user.email, subject: subject, body: body)
  end

  def status_activated(user)
    setup_email
    @user = user
    mail(to: user.email,
         subject: "#{user.name}'s Account Activated")
  end

  def publication_approval(publication, pp_committee, secretary)
    setup_email
    @publication = publication
    @user = publication.user
    @pp_committee = pp_committee
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
    mail(to: @user.email,
         subject: "Publication Proposal for #{@publication.abbreviated_title_and_ms} has been #{@approval_status}",
         reply_to: secretary.email)
  end

  def review_updated(user_publication_review, secretary)
    setup_email
    @secretary = secretary
    @user_publication_review = user_publication_review
    @reviewer = user_publication_review.user
    @publication = user_publication_review.publication

    mail(to: secretary.email,
         subject: "#{@reviewer.name} has reviewed #{@publication.abbreviated_title_and_ms}",
         reply_to: @reviewer.email
    )
  end

  protected

  def setup_email

  end

end
