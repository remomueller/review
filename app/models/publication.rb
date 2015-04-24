class Publication < ActiveRecord::Base

  STATUS = [["Not Approved", "not approved"], ["Draft", "draft"], ["Proposed", "proposed"], ["P&P Approved", "approved"],
            ["SC Approved", "nominated"], ["Submitted", "submitted"], ["Published", "published"]]

  PP_STATUS = [["Proposed","proposed"], ["P&P Approved", "approved"], ["Not Approved", "not approved"]]
  SC_STATUS = [["P&P Approved", "approved"], ["SC Approved", "nominated"], ["Not Approved", "not approved"]]

  FINAL_STATUS = [['SC Approved', 'nominated'], ['Submitted', 'submitted'], ['Published', 'published']]

  mount_uploader :manuscript, ManuscriptUploader
  mount_uploader :chat_data_main_forms_attachment, ManuscriptUploader
  mount_uploader :chat_data_main_database_attachment, ManuscriptUploader
  mount_uploader :chat_data_other_attachment, ManuscriptUploader

  mount_uploader :attachment_chat_form_attachment, ManuscriptUploader
  mount_uploader :attachment_chat_variables_attachment, ManuscriptUploader
  mount_uploader :attachment_ancillary_forms_attachment, ManuscriptUploader
  mount_uploader :attachment_other_attachment, ManuscriptUploader

  # Named Scopes
  scope :current, -> { where deleted: false }
  scope :status, lambda { |arg| where( status: arg ) }
  scope :search, lambda { |arg| where( 'LOWER(manuscript_number) LIKE ? or LOWER(full_title) LIKE ? or LOWER(abbreviated_title) LIKE ? or user_id in (SELECT users.id FROM users WHERE LOWER(users.last_name) LIKE ? or LOWER(users.first_name) LIKE ?) or co_lead_author_id in (SELECT users.id FROM users WHERE LOWER(users.last_name) LIKE ? or LOWER(users.first_name) LIKE ?)', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ) }
  scope :with_user_or_status, lambda { |*args|  where( "publications.user_id = ? or publications.status IN (?)", args.first, args[1] ) }

  # Model Validation
  validates_presence_of :full_title, :abbreviated_title

  validates_presence_of :centers, :proposed_analysis, if: :no_longer_draft?

  validates_presence_of :keywords, :affiliation, :timeline, :sponsoring_pi, :rationale, :hypothesis,
                        :data, :study_type, :target_journal, :analysis_responsibility, :analysis_plan, :summary_section, :references, if: :no_longer_draft?

  validates_presence_of :publication_type, if: :no_longer_draft?

  validates_presence_of :publication_type_specify, if: [:should_validate_publication_type?, :no_longer_draft?]

  validates_presence_of :dcc_resources_staff_specify, if: [:should_validate_dcc_resources_staff_specify?, :no_longer_draft?]
  validates_presence_of :dcc_resources_other_specify, if: [:should_validate_dcc_resources_other_specify?, :no_longer_draft?]

  validates_presence_of :manuscript_preparation_other_specify, if: [:should_validate_manuscript_preparation_other_specify?, :no_longer_draft?]

  # Model Relationships
  belongs_to :user
  has_many :user_publication_reviews
  belongs_to :co_lead_author, class_name: 'User'

  def publication_link
    ENV['website_url'] + "/publications/#{self.id}"
  end

  def abbreviated_title_and_ms
    "#{"#{self.manuscript_number} " unless self.manuscript_number.blank?}#{self.abbreviated_title}"
  end

  def full_title_and_ms
    "#{"#{self.manuscript_number} " unless self.manuscript_number.blank?}#{self.full_title}"
  end

  def reviewable?(current_user)
    ['proposed', 'approved', 'not approved', 'nominated', 'submitted', 'published'].include?(self.status) and (current_user.pp_committee? or current_user.steering_committee?)
  end

  def editable?(current_user)
    if current_user.secretary?
      true
    else
      current_user.all_publications.include?(self) and ['draft', 'not approved'].include?(self.status)
    end
  end

  def remove_nomination(nomination)
    self.user_publication_reviews.each do |upr|
      upr.remove_nomination(nomination)
    end
    self.reload
  end

  def proposed_nominations
    @proposed_nominations ||= begin
      self.user_publication_reviews.collect{|upr| upr.writing_group_nomination.to_s.split(/,|\n/)}.flatten.select{|nom| not nom.blank?}.collect{|nom| nom.strip.titleize}.uniq.sort
    end
  end

  def finalized_nominations
    @finalized_nominations ||= begin
      self.writing_group_members.split(/,|\n/).flatten.select{|nom| not nom.blank?}.collect{|nom| nom.strip.titleize}.uniq.sort
    end
  end

  def all_nominations
    @all_nominations ||= begin
      (self.finalized_nominations | self.proposed_nominations).uniq.sort
    end
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
    update_column :deleted, true
  end

  def send_reminders(current_user)
    reviewers = []
    if self.status == 'proposed'
      reviewers = (User.current.pp_committee_members | User.current.pp_secretaries)
    elsif self.status == 'approved'
      reviewers = (User.current.steering_committee_members | User.current.sc_secretaries)
    end
    reviewers.uniq.each do |reviewer|
      upr = UserPublicationReview.new(user_id: reviewer.id, publication_id: self.id)
      UserMailer.publication_approval_reminder(current_user, reviewer.email_with_name, nil, "New Publication Awaiting Approval: #{self.abbreviated_title_and_ms}", upr.email_body_template(current_user)).deliver_later if Rails.env.production?
    end
  end

  # Validations

  def should_validate_publication_type?
    self.publication_type == 'AP'
  end

  def should_validate_dcc_resources_staff_specify?
    self.dcc_resources_staff?
  end

  def should_validate_dcc_resources_other_specify?
    self.dcc_resources_other?
  end

  def should_validate_manuscript_preparation_other_specify?
    self.manuscript_preparation_other?
  end

  def no_longer_draft?
    self.status != 'draft'
  end

  def self.latex_file_location(current_user, publications)
    jobname = "publications_#{current_user.id}"
    root_folder = FileUtils.pwd
    output_folder = File.join(root_folder, 'tmp', 'files', 'tex')
    template_folder = File.join(root_folder, 'app', 'views', 'publications')
    file_template = File.join(template_folder, 'index.tex.erb')
    file_tex = File.join(root_folder, 'tmp', 'files', 'tex', jobname + '.tex')
    file_in = File.new(file_template, "r")
    file_out = File.new(file_tex, "w")
    template = ERB.new(file_in.sysread(File.size(file_in)))
    file_out.syswrite(template.result(binding))
    file_in.close()
    file_out.close()

    # Run twice to allow LaTeX to compile correctly (page numbers, etc)
    `#{ENV['latex_location']} -interaction=nonstopmode --jobname=#{jobname} --output-directory=#{output_folder} #{file_tex}`
    `#{ENV['latex_location']} -interaction=nonstopmode --jobname=#{jobname} --output-directory=#{output_folder} #{file_tex}`

    # Rails.logger.debug "----------------\n"
    # Rails.logger.debug "#{ENV['latex_location']} -interaction=nonstopmode --jobname=#{jobname} --output-directory=#{output_folder} #{file_tex}"

    file_pdf_location = File.join('tmp', 'files', 'tex', "#{jobname}.pdf")
  end

  protected

  # Escape text using +replacements+
  def self.latex_safe(text)
    replacements.inject(text.to_s) do |corpus, (pattern, replacement)|
      corpus.gsub(pattern, replacement)
    end
  end

  # List of replacements
  def self.replacements
    @replacements ||= [
      [/([{}])/,    '\\\\\1'],
      [/\\/,        '\textbackslash{}'],
      [/\^/,        '\textasciicircum{}'],
      [/~/,         '\textasciitilde{}'],
      [/\|/,        '\textbar{}'],
      [/\</,        '\textless{}'],
      [/\>/,        '\textgreater{}'],
      [/([_$&%#])/, '\\\\\1']
    ]
  end

end
