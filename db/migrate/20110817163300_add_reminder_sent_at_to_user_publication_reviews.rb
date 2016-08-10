class AddReminderSentAtToUserPublicationReviews < ActiveRecord::Migration[4.2]
  def change
    add_column :user_publication_reviews, :reminder_sent_at, :datetime
  end
end
