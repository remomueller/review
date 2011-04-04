class Publication < ActiveRecord::Base

  # STATUS = ["draft", "proposed", "approved", "not approved", "nominated", "submitted", "published"].collect{|i| [i,i]}
  STATUS = [["Draft", "draft"], ["Proposed", "proposed"], ["P&P Approved", "approved"],
            ["Not Approved", "not approved"], ["SC Approved", "nominated"], ["Submitted", "submitted"], ["Published", "published"]]
  
  # PP_STATUS = ["proposed", "approved", "not approved"].collect{|i| [i,i]}
  PP_STATUS = [["Proposed","proposed"], ["P&P Approved", "approved"], ["Not Approved", "not approved"]]
  # SC_STATUS = ["approved", "nominated", "not approved"].collect{|i| [i,i]}
  SC_STATUS = [["P&P Approved", "approved"], ["SC Approved", "nominated"], ["Not Approved", "not approved"]]

  FINAL_STATUS = [['SC Approved', 'nominated'], ['Submitted', 'submitted'], ['Published', 'published']]



  # Currently 59 Total Attributes (Publication.first.attributes.size)
  # 52 of which are attr_accessible (Publication.attr_accessible.size)
  # 7 of which are not set using mass assignment. (Publication.attr_protected.size)
  # :id, :created_at, :updated_at, :user_id, :deleted, :status, :manuscript_number, :secretary_notes
  
  attr_protected :user_id, :deleted, :manuscript_number, :secretary_notes, :targeted_start_date # , :status
  
  mount_uploader :manuscript, ManuscriptUploader
  
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

  # Model Validation
  validates_presence_of :full_title, :abbreviated_title
  
  validates_presence_of :centers, :proposed_analysis, :if => :no_longer_draft?
  
  validates_presence_of :lead_author, :writing_group_members, :keywords, :affiliation, :timeline, :sponsoring_pi, :rationale, :hypothesis, 
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
  
  validates_presence_of :attachment_chat_form_specify, :if => [:should_validate_attachment_chat_form_specify?, :no_longer_draft?]
  validates_presence_of :attachment_chat_variables_specify, :if => [:should_validate_attachment_chat_variables_specify?, :no_longer_draft?]
  validates_presence_of :attachment_ancillary_forms_specify, :if => [:should_validate_attachment_ancillary_forms_specify?, :no_longer_draft?]
  validates_presence_of :attachment_other_specify, :if => [:should_validate_attachment_other_specify?, :no_longer_draft?]
  

  # Model Relationships
  belongs_to :user
  has_many :user_publication_reviews

  def human_status
    statuses = Publication::STATUS.select{|a| a[1] == self.status}
    puts statuses.inspect
    if statuses.size > 0
      statuses.first.first
    else
      ''
    end
  end

  def destroy
    update_attribute :deleted, true
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

  def no_longer_draft?
    self.status != 'draft'
  end

end
