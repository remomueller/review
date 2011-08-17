class Publication < ActiveRecord::Base

  STATUS = [["Draft", "draft"], ["Proposed", "proposed"], ["P&P Approved", "approved"],
            ["Not Approved", "not approved"], ["SC Approved", "nominated"], ["Submitted", "submitted"], ["Published", "published"]]
  
  PP_STATUS = [["Proposed","proposed"], ["P&P Approved", "approved"], ["Not Approved", "not approved"]]
  SC_STATUS = [["P&P Approved", "approved"], ["SC Approved", "nominated"], ["Not Approved", "not approved"]]

  FINAL_STATUS = [['SC Approved', 'nominated'], ['Submitted', 'submitted'], ['Published', 'published']]

  attr_protected :user_id, :deleted, :manuscript_number, :secretary_notes, :targeted_start_date, :dataset_requested_analyst,
                 :additional_ppcommittee_instructions, :additional_sccommittee_instructions,
                 :tagged_for_pp_review, :tagged_for_sc_review
  
  mount_uploader :manuscript, ManuscriptUploader
  mount_uploader :chat_data_main_forms_attachment, ManuscriptUploader
  mount_uploader :chat_data_main_database_attachment, ManuscriptUploader
  mount_uploader :chat_data_other_attachment, ManuscriptUploader
  
  mount_uploader :attachment_chat_form_attachment, ManuscriptUploader
  mount_uploader :attachment_chat_variables_attachment, ManuscriptUploader
  mount_uploader :attachment_ancillary_forms_attachment, ManuscriptUploader
  mount_uploader :attachment_other_attachment, ManuscriptUploader
  
  # attr_accessible :full_title, :centers, :proposal_submission_date, :publication_type, :publication_type_specify, :dcc_resources_none, :dcc_resources_staff,
  #   :dcc_resources_staff_specify, :dcc_resources_other, :dcc_resources_other_specify, :chat_data_none, :chat_data_main_forms, :chat_data_main_database,
  #   :chat_data_other, :chat_data_other_specify, :manuscript_preparation_analysis_data, :manuscript_preparation_analysis_ancillary_data,
  #   :manuscript_analysis_review, :manuscript_preparation_other, :manuscript_preparation_other_specify, :manuscript_preparation_none, :proposed_analysis,
  #   :attachment_none, :attachment_chat_form,
  #   :attachment_chat_form_specify, :attachment_chat_variables, :attachment_chat_variables_specify, :attachment_ancillary_forms,
  #   :attachment_ancillary_forms_specify, :attachment_other, :attachment_other_specify, :abbreviated_title, :keywords, :affiliation, :sponsoring_pi,
  #   :additional_coauthors, :lead_author, :timeline, :rationale, :hypothesis, :data, :study_type, :target_journal, :analysis_responsibility, :analysis_plan,
  #   :summary_section, :writing_group_members, :references, :author_assurance, :author_assurance_date,
  #   :approval_date, :committee_submission_date, :manuscript


  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :status, lambda { |*args|  { :conditions => ["publications.status IN (?)", args.first] } }
  scope :search, lambda { |*args| {:conditions => [ 'LOWER(manuscript_number) LIKE ? or LOWER(full_title) LIKE ? or LOWER(abbreviated_title) LIKE ? or user_id in (SELECT users.id FROM users WHERE LOWER(users.last_name) LIKE ? or LOWER(users.first_name) LIKE ?) or co_lead_author_id in (SELECT users.id FROM users WHERE LOWER(users.last_name) LIKE ? or LOWER(users.first_name) LIKE ?)', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  
  # scope :order_by_pp_and_sc, :order => ['tagged_for_pp_review DESC', 'tagged_for_sc_review DESC']
  # scope :order_by_pp, :order => ['tagged_for_pp_review DESC']
  # scope :order_by_sc, :order => ['tagged_for_sc_review DESC'] 

  # Model Validation
  validates_presence_of :full_title, :abbreviated_title
  
  validates_presence_of :centers, :proposed_analysis, :if => :no_longer_draft?
  
  validates_presence_of :writing_group_members, :keywords, :affiliation, :timeline, :sponsoring_pi, :rationale, :hypothesis, 
                        :data, :study_type, :target_journal, :analysis_responsibility, :analysis_plan, :summary_section, :references, :if => :no_longer_draft?

  validates_presence_of :publication_type, :if => :no_longer_draft?
  
  validates_presence_of :publication_type_specify, :if => [:should_validate_publication_type?, :no_longer_draft?]
  
  validates_acceptance_of :dcc_resources_none, :message => 'select at least one', :if => [:dcc_resources_not_selected?, :no_longer_draft?]
  validates_acceptance_of :dcc_resources_staff, :message => 'select at least one', :if => [:dcc_resources_not_selected?, :no_longer_draft?]
  validates_acceptance_of :dcc_resources_other, :message => 'select at least one', :if => [:dcc_resources_not_selected?, :no_longer_draft?]

  validates_presence_of :dcc_resources_staff_specify, :if => [:should_validate_dcc_resources_staff_specify?, :no_longer_draft?]
  validates_presence_of :dcc_resources_other_specify, :if => [:should_validate_dcc_resources_other_specify?, :no_longer_draft?]

  validates_acceptance_of :chat_data_none, :message => 'select at least one', :if => [:chat_data_not_selected?, :no_longer_draft?]
  validates_acceptance_of :chat_data_main_forms, :message => 'select at least one', :if => [:chat_data_not_selected?, :no_longer_draft?]
  validates_acceptance_of :chat_data_main_database, :message => 'select at least one', :if => [:chat_data_not_selected?, :no_longer_draft?]
  validates_acceptance_of :chat_data_other, :message => 'select at least one', :if => [:chat_data_not_selected?, :no_longer_draft?]

  validates_presence_of :chat_data_other_specify, :if => [:should_validate_chat_data_other_specify?, :no_longer_draft?]

  validates_presence_of :chat_data_main_forms_attachment, :if => [:chat_data_main_forms_selected?]
  validates_presence_of :chat_data_main_database_attachment, :if => [:chat_data_main_database_selected?]
#  validates_presence_of :chat_data_other_attachment, :if => [:chat_data_other_selected?]
  
  validates_acceptance_of :manuscript_preparation_none, :message => 'select at least one', :if => [:manuscript_preparation_not_selected?, :no_longer_draft?]
  validates_acceptance_of :manuscript_preparation_analysis_data, :message => 'select at least one', :if => [:manuscript_preparation_not_selected?, :no_longer_draft?]
  validates_acceptance_of :manuscript_preparation_analysis_ancillary_data, :message => 'select at least one', :if => [:manuscript_preparation_not_selected?, :no_longer_draft?]
  validates_acceptance_of :manuscript_analysis_review, :message => 'select at least one', :if => [:manuscript_preparation_not_selected?, :no_longer_draft?]
  validates_acceptance_of :manuscript_preparation_other, :message => 'select at least one', :if => [:manuscript_preparation_not_selected?, :no_longer_draft?]
  
  validates_presence_of :manuscript_preparation_other_specify, :if => [:should_validate_manuscript_preparation_other_specify?, :no_longer_draft?]
  
  validates_acceptance_of :attachment_none, :message => 'select at least one', :if => [:attachment_not_selected?, :no_longer_draft?]
  validates_acceptance_of :attachment_chat_form, :message => 'select at least one', :if => [:attachment_not_selected?, :no_longer_draft?]
  validates_acceptance_of :attachment_chat_variables, :message => 'select at least one', :if => [:attachment_not_selected?, :no_longer_draft?]
  validates_acceptance_of :attachment_ancillary_forms, :message => 'select at least one', :if => [:attachment_not_selected?, :no_longer_draft?]
  validates_acceptance_of :attachment_other, :message => 'select at least one', :if => [:attachment_not_selected?, :no_longer_draft?]
  
  validates_presence_of :attachment_chat_form_attachment, :if => [:attachment_chat_form_selected?]
#  validates_presence_of :attachment_chat_variables_attachment, :if => [:attachment_chat_variables_selected?]
  validates_presence_of :attachment_ancillary_forms_attachment, :if => [:attachment_ancillary_forms_selected?]
#  validates_presence_of :attachment_other_attachment, :if => [:attachment_other_selected?]
  
  validates_presence_of :attachment_chat_form_specify, :if => [:should_validate_attachment_chat_form_specify?, :no_longer_draft?]
  validates_presence_of :attachment_chat_variables_specify, :if => [:should_validate_attachment_chat_variables_specify?, :no_longer_draft?]
  validates_presence_of :attachment_ancillary_forms_specify, :if => [:should_validate_attachment_ancillary_forms_specify?, :no_longer_draft?]
  validates_presence_of :attachment_other_specify, :if => [:should_validate_attachment_other_specify?, :no_longer_draft?]
  

  # Model Relationships
  belongs_to :user
  has_many :user_publication_reviews
  belongs_to :co_lead_author, :class_name => 'User'

  def abbreviated_title_and_ms
    "#{"#{self.manuscript_number} " unless self.manuscript_number.blank?}#{self.abbreviated_title}"
  end

  def full_title_and_ms
    "#{"#{self.manuscript_number} " unless self.manuscript_number.blank?}#{self.full_title}"
  end

  def targeted_start_date_pretty
    result = ''
    unless self.targeted_start_date.blank?
      if self.targeted_start_date.year == Date.today.year
        result << self.targeted_start_date.strftime('%b %d (%a)')
      else
        result << self.targeted_start_date.strftime('%b %d, %Y (%a)')
      end
    end
    result
  end
  
  def human_status
    statuses = Publication::STATUS.select{|a| a[1] == self.status}
    if statuses.size > 0
      statuses.first.first
    else
      ''
    end
  end

  def destroy
    update_attribute :deleted, true
  end

  def send_reminders
    reviewers = []
    if self.status == 'proposed'
      reviewers = (User.current.pp_committee_members | User.current.pp_secretaries)
    elsif self.status == 'approved'
      reviewers = (User.current.steering_committee_members | User.current.sc_secretaries)
    end
    reviewers.uniq.each do |reviewer|
      UserMailer.publication_approval_reminder(self, reviewer).deliver if Rails.env.production?
    end
  end

  # Validations

  def should_validate_publication_type?
    self.publication_type == 'AP'
  end

  def dcc_resources_not_selected?
    !(self.dcc_resources_none? || self.dcc_resources_staff? || self.dcc_resources_other?)
  end

  def should_validate_dcc_resources_staff_specify?
    self.dcc_resources_staff?
  end

  def should_validate_dcc_resources_other_specify?
    self.dcc_resources_other?
  end

  def chat_data_not_selected?
    !(self.chat_data_none? || self.chat_data_main_forms? || self.chat_data_main_database? || self.chat_data_other?)
  end
  
  def should_validate_chat_data_other_specify?
    self.chat_data_other?
  end
  
  def chat_data_main_forms_selected?
    self.chat_data_main_forms?
  end
  
  def chat_data_main_database_selected?
    self.chat_data_main_database?
  end
  
  def chat_data_other_selected?
    self.chat_data_other?
  end
  
  def manuscript_preparation_not_selected?
    !(self.manuscript_preparation_none? || self.manuscript_preparation_analysis_data? || self.manuscript_preparation_analysis_ancillary_data? || self.manuscript_analysis_review? || self.manuscript_preparation_other?)
  end
  
  def should_validate_manuscript_preparation_other_specify?
    self.manuscript_preparation_other?    
  end
  
  def attachment_not_selected?
    !(self.attachment_none? || self.attachment_chat_form? || self.attachment_chat_variables? || self.attachment_ancillary_forms? || self.attachment_other?)
  end

  def should_validate_attachment_chat_form_specify?
    self.attachment_chat_form?
  end
  
  def should_validate_attachment_chat_variables_specify?
    self.attachment_chat_variables?
  end

  def should_validate_attachment_ancillary_forms_specify?
    self.attachment_ancillary_forms?
  end

  def should_validate_attachment_other_specify?
    self.attachment_other?
  end

  def attachment_chat_form_selected?
    self.attachment_chat_form?
  end

  def attachment_chat_variables_selected?
    self.attachment_chat_variables?
  end

  def attachment_ancillary_forms_selected?
    self.attachment_ancillary_forms?
  end

  def attachment_other_selected?
    self.attachment_other?
  end

  def no_longer_draft?
    self.status != 'draft'
  end

end
