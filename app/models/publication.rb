class Publication < ActiveRecord::Base

  STATUS = ["proposed", "approved", "denied", "nominated", "submitted", "published"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, :conditions => { :deleted => false }

  # Model Relationships
  belongs_to :user

end
