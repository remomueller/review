class AddReminderSentAtToUserPublicationReviews < ActiveRecord::Migration
  def change
    add_column :user_publication_reviews, :reminder_sent_at, :datetime
  end
end
