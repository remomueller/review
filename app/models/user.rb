# frozen_string_literal: true

# The user class provides methods to scope resources in system that the user is
# allowed to view and edit.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  # Callbacks
  after_commit :notify_system_admins, on: :create

  STATUS = %w(active denied inactive pending).collect { |i| [i, i] }

  # Named Scopes
  scope :current, -> { where deleted: false }
  scope :status, -> (arg) { where status: arg }
  scope :search, -> (arg) { where('LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')) }
  scope :system_admins, -> { where system_admin: true }
  scope :pp_committee_members, -> { where pp_committee: true }
  scope :steering_committee_members, -> { where steering_committee: true }

  scope :pp_secretaries, -> { where pp_committee_secretary: true }
  scope :sc_secretaries, -> { where steering_committee_secretary: true }

  # Model Validation
  validates :first_name, :last_name, presence: true

  # Model Relationships
  has_many :comments, -> { where(deleted: false).order('created_at DESC') }
  has_many :publications, -> { where deleted: false }
  has_many :user_publication_reviews

  # User Methods

  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(email.to_s.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  # Overriding Devise built-in active? method
  def active_for_authentication?
    super && status == 'active' && !deleted?
  end

  def destroy
    update_column :deleted, true
    update_column :status, 'inactive'
    update_column :updated_at, Time.zone.now
  end

  def secretary?
    steering_committee_secretary? || pp_committee_secretary?
  end

  def committee_member?
    pp_committee? || steering_committee?
  end

  def all_publications
    if secretary?
      Publication.current
    else
      publications
    end
  end

  def all_viewable_publications
    if committee_member? || secretary?
      Publication.current
    else
      Publication.current.with_user_or_status(id, %w(proposed approved nominated submitted published))
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def email_with_name
    "#{name} <#{email}>"
  end

  private

  def notify_system_admins
    return unless EMAILS_ENABLED
    User.current.system_admins.each do |system_admin|
      UserMailer.notify_system_admin(system_admin, self).deliver_now
    end
  end
end
