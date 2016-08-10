class CreatePublications < ActiveRecord::Migration[4.2]
  def change
    create_table :publications do |t|
      t.integer :user_id
      t.string :status, default: 'proposed', null: false
      t.string :centers
      t.date :proposal_submission_date
      t.string :publication_type
      t.string :publication_type_specify
      t.boolean :dcc_resources_none, default: false, null: false
      t.boolean :dcc_resources_staff, default: false, null: false
      t.string :dcc_resources_staff_specify
      t.boolean :dcc_resources_other, default: false, null: false
      t.string :dcc_resources_other_specify
      t.boolean :chat_data_none, default: false, null: false
      t.boolean :chat_data_main_forms, default: false, null: false
      t.boolean :chat_data_main_database, default: false, null: false
      t.boolean :chat_data_other, default: false, null: false
      t.string :chat_data_other_specify
      t.boolean :manuscript_preparation_analysis_data, default: false, null: false
      t.boolean :manuscript_preparation_analysis_ancillary_data, default: false, null: false
      t.boolean :manuscript_analysis_review, default: false, null: false
      t.boolean :manuscript_preparation_other, default: false, null: false
      t.string :manuscript_preparation_other_specify
      t.boolean :manuscript_preparation_none, default: false, null: false
      t.boolean :attachment_chat_form, default: false, null: false
      t.string :attachment_chat_form_specify
      t.boolean :attachment_chat_variables, default: false, null: false
      t.string :attachment_chat_variables_specify
      t.boolean :attachment_ancillary_forms, default: false, null: false
      t.string :attachment_ancillary_forms_specify
      t.boolean :attachment_other, default: false, null: false
      t.string :attachment_other_specify
      t.string :full_title
      t.string :abbreviated_title, limit: 40
      t.string :keywords
      t.string :affiliation
      t.string :sponsoring_pi
      t.string :additional_coauthors
      t.string :lead_author
      t.text :timeline
      t.text :rationale
      t.text :hypothesis
      t.text :data
      t.string :study_type
      t.string :target_journal
      t.text :analysis_responsibility
      t.text :analysis_plan
      t.text :summary_section
      t.string :writing_group_members
      t.text :references
      t.boolean :author_assurance, default: false, null: false
      t.date :author_assurance_date
      t.date :approval_date
      t.date :committee_submission_date
      t.boolean :deleted, default: false, null: false
      t.timestamps
    end
  end
end
