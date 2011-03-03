class Publication < ActiveRecord::Base

  STATUS = ["proposed", "approved", "not approved", "approved with comments", "nominated", "submitted", "published"].collect{|i| [i,i]}
  PP_STATUS = ["approved", "approved with comments", "not approved"].collect{|i| [i,i]}
  # Currently 57 Total Attributes (Publication.first.attributes.size)
  # 52 of which are attr_accessible (Publication.attr_accessible.size)
  # 5 of which are not set using mass assignment.
  # :id, :created_at, :updated_at, :user_id, :deleted
  
  # attr_protected :user_id, :deleted
  
  attr_accessible :full_title, :centers, :proposal_submission_date, :publication_type, :publication_type_specify, :dcc_resources_none, :dcc_resources_staff,
    :dcc_resources_staff_specify, :dcc_resources_other, :dcc_resources_other_specify, :chat_data_none, :chat_data_main_forms, :chat_data_main_database,
    :chat_data_other, :chat_data_other_specify, :manuscript_preparation_analysis_data, :manuscript_preparation_analysis_ancillary_data,
    :manuscript_analysis_review, :manuscript_preparation_other, :manuscript_preparation_other_specify, :manuscript_preparation_none, :attachment_chat_form,
    :attachment_chat_form_specify, :attachment_chat_variables, :attachment_chat_variables_specify, :attachment_ancillary_forms,
    :attachment_ancillary_forms_specify, :attachment_other, :attachment_other_specify, :abbreviated_title, :keywords, :affiliation, :sponsoring_pi,
    :additional_coauthors, :lead_author, :timeline, :rationale, :hypothesis, :data, :study_type, :target_journal, :analysis_responsibility, :analysis_plan,
    :summary_section, :writing_group_members, :references, :author_assurance, :author_assurance_date,
    :approval_date, :committee_submission_date, :status, :manuscript_number


  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :status, lambda { |*args|  { :conditions => ["publications.status IN (?)", args.first] } }

  # Model Validation
  validates_presence_of :full_title

  # Model Relationships
  belongs_to :user
  has_many :user_publication_reviews

  def destroy
    update_attribute :deleted, true
  end

end
