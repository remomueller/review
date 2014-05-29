class UserMailerPreview < ActionMailer::Preview

  def notify_system_admin
    system_admin = User.current.first
    user = User.current.first
    UserMailer.notify_system_admin(system_admin, user)
  end

  def status_activated
    user = User.current.first
    UserMailer.status_activated(user)
  end

  def publication_approval
    publication = Publication.current.first
    pp_committee = true
    secretary = User.current.first
    UserMailer.publication_approval(publication, pp_committee, secretary)
  end

  def review_updated
    user_publication_review = UserPublicationReview.current.first
    secretary = User.current.first
    UserMailer.review_updated(user_publication_review, secretary)
  end

end
