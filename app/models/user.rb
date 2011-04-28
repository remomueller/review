class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, and :lockable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name
  
  after_create :notify_system_admins
  before_update :status_activated

  STATUS = ["active", "denied", "inactive", "pending"].collect{|i| [i,i]}
  
  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :status, lambda { |*args|  { :conditions => ["users.status IN (?)", args.first] } }
  scope :search, lambda { |*args| {:conditions => [ 'LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :system_admins, :conditions => { :system_admin => true }
  scope :pp_committee_members, :conditions => { :pp_committee => true }
  scope :steering_committee_members, :conditions => { :steering_committee => true }
  
  scope :pp_secretaries, :conditions => { :pp_committee_secretary => true }
  scope :sc_secretaries, :conditions => { :steering_committee_secretary => true }
  
  
  # Model Validation
  validates_presence_of     :first_name
  validates_presence_of     :last_name

  # Model Relationships
  has_many :authentications
  has_many :comments, :conditions => {:deleted => false}, :order => 'created_at DESC'
  has_many :publications, :conditions => { :deleted => false }
  has_many :user_publication_reviews
  
  # User Methods
  
  # Overriding Devise built-in active? method
  def active?
    super and self.status == 'active' and not self.deleted?
  end
  
  def destroy
    update_attribute :deleted, true
    update_attribute :status, 'inactive'
  end
  
  def secretary?
    self.steering_committee_secretary? || self.pp_committee_secretary?
  end
  
  def committee_member?
    self.pp_committee? or self.steering_committee?
  end
  
  def all_publications
    @all_publications ||= begin
      self.publications
    end
  end
  
  def all_viewable_publications
    @all_viewable_publications ||= begin
      if self.committee_member? or self.secretary?
        Publication.current
      else
        self.publications
      end
    end
  end
  
  def all_comments
    @all_comments ||= begin
      if self.system_admin?
        Comment.current.order('created_at DESC')
      else
        self.comments
      end
    end
  end

  def name
    "#{first_name} #{last_name}"
  end
  
  def rev_name
    "#{last_name}, #{first_name}"
  end
  
  def apply_omniauth(omniauth)
    unless omniauth['user_info'].blank?
      self.email = omniauth['user_info']['email'] if email.blank?
      self.first_name = omniauth['user_info']['first_name'] if first_name.blank?
      self.last_name = omniauth['user_info']['last_name'] if last_name.blank?
    end
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
  
  private
  
  def notify_system_admins
    User.current.system_admins.each do |system_admin|
      UserMailer.notify_system_admin(system_admin, self).deliver if Rails.env.production?
    end
  end
  
  def status_activated
    unless self.new_record? or self.changes.blank?
      if self.changes['status'] and self.changes['status'][1] == 'active'
        UserMailer.status_activated(self).deliver if Rails.env.production?
      end
    end
  end
end
