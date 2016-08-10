# frozen_string_literal: true

# Allow publications to be created, viewed, and discussed
class PublicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_publication, only: [ :show ]
  before_action :set_editable_publication, only: [ :edit, :update, :destroy ]
  before_action :redirect_without_publication, only: [ :show, :edit, :update, :destroy ]

  def archive
    if current_user.secretary? and @publication = Publication.current.find_by_id(params[:id])
      @publication.update_column :archived, (params[:undo] != 'true')
      render 'inline_update'
    else
      render nothing: true
    end
  end

  # def print_latex
  def print
    @order = 'manuscript_number desc'
    @publications = current_user.all_viewable_publications.order(@order).page(1).per(-1)

    file_pdf_location = Publication.latex_file_location(current_user, @publications)

    if File.exists?(file_pdf_location)
      File.open(file_pdf_location, 'r') do |file|
        send_file file, filename: "publication_matrix.pdf", type: "application/pdf", disposition: "inline"
      end
    else
      render text: "PDF did not render in time. Please refresh the page."
    end
  end

  def tag_for_review
    @committee = params[:committee]
    if current_user.pp_committee_secretary? and params[:committee] == 'pp' and @publication = Publication.current.find_by_id(params[:id])
      @publication.update_column :tagged_for_pp_review, (params[:tagged] == '1')
    elsif current_user.steering_committee_secretary? and params[:committee] == 'sc' and @publication = Publication.current.find_by_id(params[:id])
      @publication.update_column :tagged_for_sc_review, (params[:tagged] == '1')
    else
      render nothing: true
    end
  end

  def send_reminder
    @publication = Publication.current.find_by_id(params[:id])
    @reviewer = User.current.find_by_id(params[:reviewer_id])
    if @publication && @reviewer && current_user.secretary?
      @user_publication_review = @reviewer.user_publication_reviews.find_by_publication_id(@publication.id)
      @user_publication_review = @reviewer.user_publication_reviews.create(publication_id: @publication.id) if @user_publication_review.blank?
      @user_publication_review.update_column :reminder_sent_at, Time.zone.now
      UserMailer.publication_approval_reminder(current_user, params[:to], params[:cc], params[:subject], params[:body].to_s).deliver_now if EMAILS_ENABLED
    else
      render nothing: true
    end
  end

  def edit_manuscript
    @publication = current_user.secretary? ? Publication.current.find_by_id(params[:id]) : current_user.all_publications.find_by_id(params[:id])
    if @publication and ['nominated', 'submitted', 'published'].include?(@publication.status)
      render 'publications/manuscripts/edit_manuscript'
    else
      render nothing: true
    end
  end

  def show_manuscript
    @publication = current_user.all_viewable_publications.find_by_id(params[:id])
    if @publication and ['nominated', 'submitted', 'published'].include?(@publication.status)
      render 'publications/manuscripts/show_manuscript'
    else
      render nothing: true
    end
  end

  # Unfortunately a Remote Multipart Form submission isn't a built-in HTML feature...
  def upload_manuscript
    @publication = current_user.secretary? ? Publication.current.find_by_id(params[:id]) : current_user.all_publications.find_by_id(params[:id])
    if @publication and ['nominated', 'submitted', 'published'].include?(@publication.status) and params[:publication] and params[:publication][:manuscript]
      # # Remove any existing manuscripts!
      # @publication.remove_manuscript!

      @publication.update manuscript: params[:publication][:manuscript], manuscript_uploaded_at: Time.zone.now

      extension = params[:publication][:manuscript].original_filename.downcase.split('.').last
      message = ManuscriptUploader.new.extension_white_list.include?(extension) ? nil : "Not a valid document type: #{extension}"
      flash[:notice] = 'Manuscript was successfully uploaded.' if message.blank?

      redirect_to @publication, alert: message
      # render 'publications/manuscripts/show_manuscript'
    elsif @publication
      redirect_to @publication, notice: 'Please specify a file to upload.'
      # render 'publications/manuscripts/edit_manuscript'
    else
      redirect_to root_path
      # render nothing: true
    end
  end

  def destroy_manuscript
    @publication = current_user.secretary? ? Publication.current.find_by_id(params[:id]) : current_user.all_publications.find_by_id(params[:id])
    if @publication
      @publication.remove_manuscript!
      @publication.update remove_manuscript: true
      render 'publications/manuscripts/edit_manuscript'
    else
      render nothing: true
    end
  end

  def pp_approval
    @publication = Publication.current.find_by_id(params[:id])
    if @publication && current_user.pp_committee_secretary? && params[:publication]
      @publication.update(params.require(:publication).permit(:status, :manuscript_number, :additional_ppcommittee_instructions))
      UserMailer.publication_approval(@publication, true, current_user).deliver_now if @publication.status != 'proposed' && @publication.user && EMAILS_ENABLED
      @publication.send_reminders(current_user) if @publication.status == 'approved'
      redirect_to @publication
    else
      redirect_to root_path
    end
  end

  def show_subcommittee_decision
    render nothing: true unless current_user.pp_committee_secretary? and @publication = Publication.current.find_by_id(params[:id])
  end

  def edit_subcommittee_decision
    render nothing: true unless current_user.pp_committee_secretary? and @publication = Publication.current.find_by_id(params[:id])
  end

  def sc_approval
    @publication = Publication.current.find_by_id(params[:id])
    if @publication && current_user.steering_committee_secretary? && params[:publication]
      @publication.update(params.require(:publication).permit(:status, :additional_sccommittee_instructions))
      UserMailer.publication_approval(@publication, false, current_user).deliver_now if @publication.status != 'approved' && @publication.user && EMAILS_ENABLED
      redirect_to @publication
    else
      redirect_to root_path
    end
  end

  def show_steering_committee_decision
    render nothing: true unless current_user.steering_committee_secretary? and @publication = Publication.current.find_by_id(params[:id])
  end

  def edit_steering_committee_decision
    render nothing: true unless current_user.steering_committee_secretary? and @publication = Publication.current.find_by_id(params[:id])
  end

  def index
    flash.delete(:notice)
  	first_visit = params[:order].blank?

    publications_scope = current_user.all_viewable_publications

    @archived = params[:archived] || 'unarchived'
    publications_scope = publications_scope.where(archived: (params[:archived] == 'archived'))

    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| publications_scope = publications_scope.search(search_term) }


    @order = scrub_order(Publication, params[:order], 'manuscript_number DESC')

    if first_visit
      if (current_user.pp_committee? or current_user.pp_committee_secretary?) and (current_user.steering_committee? or current_user.steering_committee_secretary?)
        @order = ['publications.tagged_for_pp_review DESC', 'publications.tagged_for_sc_review DESC']
      elsif (current_user.pp_committee? or current_user.pp_committee_secretary?)
        @order = 'publications.tagged_for_pp_review DESC'
      elsif (current_user.steering_committee? or current_user.steering_committee_secretary?)
        @order = 'publications.tagged_for_sc_review DESC'
      end
    end

    publications_scope = publications_scope.order(@order)



    @publications = publications_scope.page(params[:page]).per( 40 )
  end

  # GET /publications/1
  # GET /publications/1.json
  def show
  end

  # GET /publications/new
  def new
    @publication = current_user.publications.new
  end

  # GET /publications/1/edit
  def edit
    redirect_to root_path unless @publication.editable?(current_user)
  end

  def inline_update
    if current_user.secretary? and @publication = Publication.current.find_by_id(params[:id]) and params[:publication]
      params[:publication][:targeted_start_date] = parse_date(params[:publication][:targeted_start_date])

      @publication.update(params.require(:publication).permit(:manuscript_number, :user_id, :co_lead_author_id, :writing_group_members, :status, :dataset_requested_analyst, :targeted_start_date, :secretary_notes))

      render 'inline_update'
    else
      render nothing: true
    end
  end

  def create
    @publication = (current_user.secretary? ? Publication.new(publication_params) : current_user.publications.new(publication_params))

    if @publication.save
      @publication.send_reminders(current_user) if params[:publish] == '1' and not current_user.secretary?
      if params[:publish] == '-1'
        flash[:notice] = "Publication draft was successfully quick saved."
        render action: "new"
      else
        notice = ''
        if current_user.secretary?
          notice = 'Publication was successfully created.'
        else
          notice = (params[:publish] == '1' ? 'Publication was successfully submitted for review.' : 'Publication draft was successfully created.')
        end
        redirect_to(@publication, notice: notice)
      end
    else
      flash[:alert] = "#{@publication.errors.count} error#{ 's' unless @publication.errors.count == 1} prohibited this publication from being saved." if @publication.errors.any?
      render action: 'new'
    end
  end

  def update
    redirect_to root_path unless @publication.editable?(current_user)

    if @publication.update(publication_params)
      @publication.send_reminders(current_user) if params[:publish] == '1' and not current_user.secretary?
      if params[:publish] == '-1'
        flash[:notice] = "Publication draft was successfully quick saved."
        render action: "edit"
      else
        notice = ''
        if current_user.secretary?
          notice = 'Publication was successfully updated.'
        else
          notice = (params[:publish] == '1' ? 'Publication was successfully resubmitted for review.' : 'Publication draft was saved successfully.')
        end
        redirect_to(@publication, notice: notice)
      end
    else
      flash[:alert] = "#{@publication.errors.count} error#{ 's' unless @publication.errors.count == 1} prohibited this publication from being updated." if @publication.errors.any?
      render action: "edit"
    end
  end

  # DELETE /publications/1
  # DELETE /publications/1.json
  def destroy
    @publication.destroy

    respond_to do |format|
      format.html { redirect_to publications_path }
      format.js { render 'destroy' }
      format.json { head :no_content }
    end
  end

  def remove_nomination
    @publication = Publication.current.find_by_id(params[:id])
    if @publication and current_user.secretary?
      @publication.remove_nomination(params[:nomination])
      render 'committee_nominations'
    else
      render nothing: true
    end
  end

  private

    def set_viewable_publication
      @publication = current_user.all_viewable_publications.find_by_id(params[:id])
    end

    def set_editable_publication
      @publication = current_user.all_publications.find_by_id(params[:id])
    end

    def redirect_without_publication
      empty_response_or_root_path(publications_path) unless @publication
    end

    def publication_params
      params[:publication] ||= {}

      params[:publication][:status] = (params[:publish] == '1') ? 'proposed' : 'draft' unless current_user.secretary?
      params[:publication][:author_assurance_date] = Date.today if params[:publish] == '1'

      [:proposal_submission_date].each do |date|
        params[:publication][date] = parse_date(params[:publication][date])
      end

      if current_user.secretary?
        params.require(:publication).permit(
          # Secretary Only
          :user_id, :archived,
          # Automatically added
          :status, :author_assurance_date,
          # Required to save draft
          :full_title, :abbreviated_title,
          # A. Administrative Information
          :centers, :proposal_submission_date,
          # B. Publication Information
          :publication_type, :publication_type_specify,
          # C. CHAT Resources
          :dcc_resources_none, :dcc_resources_staff, :dcc_resources_staff_specify, :dcc_resources_other, :dcc_resources_other_specify,
          :chat_data_none,
          :chat_data_main_forms, :chat_data_main_forms_attachment, :chat_data_main_forms_attachment_cache,
          :chat_data_main_database, :chat_data_main_database_attachment, :chat_data_main_database_attachment_cache,
          :chat_data_other, :chat_data_other_attachment, :chat_data_other_attachment_cache,
          :chat_data_other_specify,
          # D. Data Analysis
          :manuscript_preparation_none, :manuscript_preparation_analysis_data, :manuscript_preparation_analysis_ancillary_data, :manuscript_analysis_review, :manuscript_preparation_other, :manuscript_preparation_other_specify,
          :proposed_analysis,
          # E. Attachments
          :attachment_none,
          :attachment_chat_form, :attachment_chat_form_attachment, :attachment_chat_form_attachment_cache, :attachment_chat_form_specify,
          :attachment_chat_variables, :attachment_chat_variables_attachment, :attachment_chat_variables_attachment_cache, :attachment_chat_variables_specify,
          :attachment_ancillary_forms, :attachment_ancillary_forms_attachment, :attachment_ancillary_forms_attachment_cache, :attachment_ancillary_forms_specify,
          :attachment_other, :attachment_other_attachment, :attachment_other_attachment_cache, :attachment_other_specify,
          # 10. CHAT Publication Proposal Description
          :co_lead_author_id, :writing_group_members, :keywords, :affiliation, :timeline,
          :sponsoring_pi, :rationale, :hypothesis, :data, :study_type, :target_journal,
          :analysis_responsibility, :analysis_plan, :summary_section, :references,
          :additional_comments,
          # F. Author assurance and sign off
          :author_assurance
        )
      else
        params.require(:publication).permit(
          # Automatically added
          :status, :author_assurance_date,
          # Required to save draft
          :full_title, :abbreviated_title,
          # A. Administrative Information
          :centers, :proposal_submission_date,
          # B. Publication Information
          :publication_type, :publication_type_specify,
          # C. CHAT Resources
          :dcc_resources_none, :dcc_resources_staff, :dcc_resources_staff_specify, :dcc_resources_other, :dcc_resources_other_specify,
          :chat_data_none,
          :chat_data_main_forms, :chat_data_main_forms_attachment, :chat_data_main_forms_attachment_cache,
          :chat_data_main_database, :chat_data_main_database_attachment, :chat_data_main_database_attachment_cache,
          :chat_data_other, :chat_data_other_attachment, :chat_data_other_attachment_cache,
          :chat_data_other_specify,
          # D. Data Analysis
          :manuscript_preparation_none, :manuscript_preparation_analysis_data, :manuscript_preparation_analysis_ancillary_data, :manuscript_analysis_review, :manuscript_preparation_other, :manuscript_preparation_other_specify,
          :proposed_analysis,
          # E. Attachments
          :attachment_none,
          :attachment_chat_form, :attachment_chat_form_attachment, :attachment_chat_form_attachment_cache, :attachment_chat_form_specify,
          :attachment_chat_variables, :attachment_chat_variables_attachment, :attachment_chat_variables_attachment_cache, :attachment_chat_variables_specify,
          :attachment_ancillary_forms, :attachment_ancillary_forms_attachment, :attachment_ancillary_forms_attachment_cache, :attachment_ancillary_forms_specify,
          :attachment_other, :attachment_other_attachment, :attachment_other_attachment_cache, :attachment_other_specify,
          # 10. CHAT Publication Proposal Description
          :co_lead_author_id, :writing_group_members, :keywords, :affiliation, :timeline,
          :sponsoring_pi, :rationale, :hypothesis, :data, :study_type, :target_journal,
          :analysis_responsibility, :analysis_plan, :summary_section, :references,
          :additional_comments,
          # F. Author assurance and sign off
          :author_assurance
        )
      end
    end

end
