class UserPublicationReview < ActiveRecord::Base

  STATUS = ["approved", "not approved"].collect{|i| [i,i]}

  after_update :notify_sc_secretary

  # Named Scopes
  scope :current, :conditions => { }
  scope :status, lambda { |*args|  { :conditions => ["user_publication_reviews.status IN (?)", args.first] } }

  # Model Relationships
  belongs_to :publication
  belongs_to :user

  # User Publication Review Methods

  private
  
  # If a steering committee member creates or updates their review of a publication
  # after the steering committee secretary has marked it as SC Approved
  # then send the Steering Committee secretary an email with that review and link to publication.
  def notify_sc_secretary
    if self.publication and ['nominated', 'submitted', 'published'].include?(self.publication.status)
      User.sc_secretaries.each do |secretary|
        UserMailer.review_updated(self, secretary).deliver if Rails.env.production?
      end
    end
  end
  
end
