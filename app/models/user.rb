class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name
  
  after_create :notify_system_admins

  STATUS = ["active", "denied", "inactive", "pending"].collect{|i| [i,i]}
  
  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :status, lambda { |*args|  { :conditions => ["users.status IN (?)", args.first] } }
  scope :system_admins, :conditions => { :system_admin => true }
  scope :pp_committee_members, :conditions => { :pp_committee => true }
  
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
  
  def all_publications
    @all_publications ||= begin
      if self.system_admin?
        Publication.current.order('created_at')
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
      UserMailer.notify_system_admin(system_admin, self).deliver
    end
  end
end
