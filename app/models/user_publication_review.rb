# frozen_string_literal: true

# Defines how publications can be reviewed by committee members
class UserPublicationReview < ActiveRecord::Base
  # attr_accessible :status, :comment, :writing_group_nomination, :publication_id

  STATUS = ['approved', 'not approved'].collect { |i| [i, i] }

  before_update :notify_sc_secretary

  # Named Scopes
  scope :current, -> { all }

  # Model Relationships
  belongs_to :publication
  belongs_to :user

  # User Publication Review Methods

  def remove_nomination(nomination)
    modified_writing_group = writing_group_nomination.to_s.split(/,|\n/)
                                                     .select(&:present?)
                                                     .collect { |nom| nom.strip.titleize }
                                                     .select { |nom| nom != nomination }
                                                     .uniq.sort.join(',')
    # Update without firing callbacks
    update_column :writing_group_nomination, modified_writing_group
  end

  def email_body_template(current_user)
    %(Hello #{user.first_name},\n
#{"#{publication.user.email_with_name} has submitted a publication proposal #{publication.created_at.strftime('on %b %d, %Y at %I:%M %p')}.\n" if publication.user}
#{"A publication proposal was submitted #{publication.created_at.strftime("on %b %d, %Y at %I:%M %p")}.\n" unless publication.user}
#{publication.full_title_and_ms}\n\n
Please follow the link #{ENV['website_url']}/publications/#{publication.id} to approve or deny the proposal.\n
Thank you!\n
#{ENV['website_name']} System Mailer\n)
  end

  private

  # If a steering committee member creates or updates their review of a publication
  # after the steering committee secretary has marked it as SC Approved
  # then send the Steering Committee secretary an email with that review and link to publication.
  def notify_sc_secretary
    return unless EMAILS_ENABLED && publication && %w(nominated submitted published).include?(publication.status)
    return if changes[:comment].blank? && changes[:writing_group_nomination].blank? && changes[:status].blank?
    User.sc_secretaries.each do |secretary|
      UserMailer.review_updated(self, secretary).deliver_later
    end
  end
end
