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
  
  attr_protected :user_id, :deleted, :status, :manuscript_number, :secretary_notes, :targeted_start_date
  
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
  validates_presence_of :full_title
  
  validates_presence_of :centers, :proposed_analysis
  
  validates_presence_of :abbreviated_title, :lead_author, :writing_group_members, :keywords, :affiliation, :timeline, :sponsoring_pi,
                        :rationale, :hypothesis, :data, :study_type, :target_journal, :analysis_responsibility, :analysis_plan, :summary_section,
                        :references

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

end
