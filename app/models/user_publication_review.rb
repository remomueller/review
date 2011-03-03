class UserPublicationReview < ActiveRecord::Base

  STATUS = ["approved", "approved with comments", "not approved"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, :conditions => { }
  scope :status, lambda { |*args|  { :conditions => ["user_publication_reviews.status IN (?)", args.first] } }

  # Model Relationships
  belongs_to :publication
  belongs_to :user
end
