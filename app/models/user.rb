class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  # Callbacks
  after_create :notify_system_admins

  STATUS = ["active", "denied", "inactive", "pending"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, -> { where deleted: false }
  scope :status, lambda { |arg|  where( status: arg ) }
  scope :search, lambda { |arg| where( 'LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ) }
  scope :system_admins, -> { where system_admin: true }
  scope :pp_committee_members, -> { where pp_committee: true }
  scope :steering_committee_members, -> { where steering_committee: true }

  scope :pp_secretaries, -> { where pp_committee_secretary: true }
  scope :sc_secretaries, -> { where steering_committee_secretary: true }


  # Model Validation
  validates_presence_of     :first_name
  validates_presence_of     :last_name

  # Model Relationships
  has_many :comments, -> { where( deleted: false ).order('created_at DESC') }
  has_many :publications, -> { where deleted: false }
  has_many :user_publication_reviews

  # User Methods

  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(self.email.to_s.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  # Overriding Devise built-in active? method
  def active_for_authentication?
    super and self.status == 'active' and not self.deleted?
  end

  def destroy
    update_column :deleted, true
    update_column :status, 'inactive'
    update_column :updated_at, Time.now
  end

  def secretary?
    self.steering_committee_secretary? || self.pp_committee_secretary?
  end

  def committee_member?
    self.pp_committee? or self.steering_committee?
  end

  def all_publications
    @all_publications ||= begin
      if self.secretary?
        Publication.current
      else
        self.publications
      end
    end
  end

  def all_viewable_publications
    @all_viewable_publications ||= begin
      if self.committee_member? or self.secretary?
        Publication.current
      else
        Publication.current.with_user_or_status(self.id, ['proposed', 'approved', 'nominated', 'submitted', 'published'])
      end
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
    User.current.system_admins.each do |system_admin|
      UserMailer.notify_system_admin(system_admin, self).deliver_later if Rails.env.production?
    end
  end
end
