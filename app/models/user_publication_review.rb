class UserPublicationReview < ActiveRecord::Base

  # attr_accessible :status, :comment, :writing_group_nomination, :publication_id

  STATUS = ["approved", "not approved"].collect{|i| [i,i]}

  before_update :notify_sc_secretary

  # Named Scopes
  scope :current, -> { all }
  scope :status, lambda { |args| where( status: arg ) }

  # Model Relationships
  belongs_to :publication
  belongs_to :user

  # User Publication Review Methods

  def remove_nomination(nomination)
    modified_writing_group = self.writing_group_nomination.to_s.split(/,|\n/).select{|nom| not nom.blank?}.collect{|nom| nom.strip.titleize}.uniq.select{|nom| nom != nomination}.sort.join(',')
    # Update without firing callbacks
    self.update_column :writing_group_nomination, modified_writing_group
  end

  def email_body_template(current_user)
    result = ""
    result << "Hello #{self.user.first_name},\n"
    if self.publication.user
      result << "\n#{self.publication.user.email_with_name} has submitted a publication proposal #{self.publication.created_at.strftime("on %b %d, %Y at %I:%M %p")}.\n"
    else
      result << "\nA publication proposal was submitted #{self.publication.created_at.strftime("on %b %d, %Y at %I:%M %p")}.\n"
    end
    result << "  \n#{self.publication.full_title_and_ms}\n"
    result << "\nPlease follow the link #{ENV['website_url']}/publications/#{self.publication.id} to approve or deny the proposal.\n"
    result << "\nThank you!\n"
    result << "\n#{ENV['website_name']} System Mailer\n"
    result
  end

  private

  # If a steering committee member creates or updates their review of a publication
  # after the steering committee secretary has marked it as SC Approved
  # then send the Steering Committee secretary an email with that review and link to publication.
  def notify_sc_secretary
    unless self.changes[:comment].blank? and self.changes[:writing_group_nomination].blank? and self.changes[:status].blank?
      if self.publication and ['nominated', 'submitted', 'published'].include?(self.publication.status)
        User.sc_secretaries.each do |secretary|
          UserMailer.review_updated(self, secretary).deliver_later if Rails.env.production?
        end
      end
    end
  end

end
