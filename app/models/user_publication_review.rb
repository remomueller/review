class UserPublicationReview < ActiveRecord::Base

  attr_accessible :user_id, :publication_id, :status, :comment, :writing_group_nomination, :reminder_sent_at

  STATUS = ["approved", "not approved"].collect{|i| [i,i]}

  before_update :notify_sc_secretary

  # Named Scopes
  scope :current, conditions: { }
  scope :status, lambda { |*args|  { conditions: ["user_publication_reviews.status IN (?)", args.first] } }

  # Model Relationships
  belongs_to :publication
  belongs_to :user

  # User Publication Review Methods

  def remove_nomination(nomination)
    modified_writing_group = self.writing_group_nomination.to_s.split(/,|\n/).select{|nom| not nom.blank?}.collect{|nom| nom.strip.titleize}.uniq.select{|nom| nom != nomination}.sort.join(',')
    # Update without firing callbacks
    self.update_column :writing_group_nomination, modified_writing_group
  end

  private

  # If a steering committee member creates or updates their review of a publication
  # after the steering committee secretary has marked it as SC Approved
  # then send the Steering Committee secretary an email with that review and link to publication.
  def notify_sc_secretary
    unless self.changes[:comment].blank? and self.changes[:writing_group_nomination].blank? and self.changes[:status].blank?
      if self.publication and ['nominated', 'submitted', 'published'].include?(self.publication.status)
        User.sc_secretaries.each do |secretary|
          UserMailer.review_updated(self, secretary).deliver if Rails.env.production?
        end
      end
    end
  end

end
