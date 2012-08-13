class PublicationsController < ApplicationController
  before_filter :authenticate_user!

  def print
    @order = 'manuscript_number'
    @publications = current_user.all_viewable_publications.order(:manuscript_number).page(1).per(-1)
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
    if current_user.secretary? and @publication = Publication.current.find_by_id(params[:id]) and @reviewer = User.current.find_by_id(params[:reviewer_id])
      @user_publication_review = @reviewer.user_publication_reviews.find_by_publication_id(@publication.id)
      @user_publication_review = @reviewer.user_publication_reviews.create(publication_id: @publication.id) if @user_publication_review.blank?
      @user_publication_review.update_attributes reminder_sent_at: Time.now

      UserMailer.publication_approval_reminder(@publication, @reviewer).deliver if Rails.env.production?
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

      @publication.update_attributes manuscript: params[:publication][:manuscript], manuscript_uploaded_at: Time.now

      extension = params[:publication][:manuscript].original_filename.downcase.split('.').last
      message = ManuscriptUploader.new.extension_white_list.include?(extension) ? nil : "Not a valid document type: #{extension}"
      flash[:notice] = "Manuscript was successfully uploaded." if message.blank?

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
      @publication.update_attributes remove_manuscript: true
      render 'publications/manuscripts/edit_manuscript'
    else
      render nothing: true
    end
  end

  def pp_approval
    if current_user.pp_committee_secretary? and @publication = Publication.current.find_by_id(params[:id]) and params[:publication]
      [:status, :manuscript_number, :additional_ppcommittee_instructions].each do |attribute|
        @publication.update_column attribute, params[:publication][attribute]
      end
      UserMailer.publication_approval(@publication, true, current_user).deliver if @publication.status != 'proposed' and @publication.user and Rails.env.production?
      @publication.send_reminders if @publication.status == 'approved'
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
    if current_user.steering_committee_secretary? and @publication = Publication.current.find_by_id(params[:id]) and params[:publication]
      [:status, :additional_sccommittee_instructions].each do |attribute|
        @publication.update_column attribute, params[:publication][attribute]
      end
      UserMailer.publication_approval(@publication, false, current_user).deliver if @publication.status != 'approved' and @publication.user and Rails.env.production?
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
  	first_visit = params[:order].blank?

    publications_scope = current_user.all_viewable_publications
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| publications_scope = publications_scope.search(search_term) }


    @order = scrub_order(Publication, params[:order], 'manuscript_number DESC')

    if first_visit
      if (current_user.pp_committee? or current_user.pp_committee_secretary?) and (current_user.steering_committee? or current_user.steering_committee_secretary?)
        @order = ['tagged_for_pp_review DESC', 'tagged_for_sc_review DESC']
      elsif (current_user.pp_committee? or current_user.pp_committee_secretary?)
        @order = 'tagged_for_pp_review DESC'
      elsif (current_user.steering_committee? or current_user.steering_committee_secretary?)
        @order = 'tagged_for_sc_review DESC'
      end
    end

    publications_scope = publications_scope.order(@order)



    @publications = publications_scope.page(params[:page]).per(10)
  end

  def show
    @publication = current_user.all_viewable_publications.find_by_id(params[:id])
    redirect_to root_path unless @publication
  end

  def new
    @publication = current_user.publications.new
  end

  def edit
    @publication = current_user.all_publications.find_by_id(params[:id])
    redirect_to root_path unless @publication and @publication.editable?(current_user)
  end

  def inline_update
    if current_user.secretary? and @publication = Publication.current.find_by_id(params[:id]) and params[:publication]
      params[:publication][:targeted_start_date] = parse_date(params[:publication][:targeted_start_date])

      params[:publication].keys.each do |attribute|
        @publication.update_column attribute, params[:publication][attribute]
      end

      render 'inline_update'
    else
      render nothing: true
    end
  end

  def create
    params[:publication][:status] = (params[:publish] == '1') ? 'proposed' : 'draft' unless current_user.secretary?
    params[:publication][:author_assurance_date] = Date.today if params[:publish] == '1'
    @publication = current_user.publications.new(params[:publication])

    if @publication.save
      @publication.send_reminders if params[:publish] == '1' and not current_user.secretary?
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
      render action: "new"
    end
  end

  def update
    @publication = current_user.all_publications.find_by_id(params[:id])
    if @publication and @publication.editable?(current_user)
      params[:publication][:status] = (params[:publish] == '1') ? 'proposed' : 'draft' unless current_user.secretary?
      params[:publication][:author_assurance_date] = Date.today if params[:publish] == '1'
      if @publication.update_attributes(params[:publication])
        @publication.send_reminders if params[:publish] == '1' and not current_user.secretary?
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
    else
      redirect_to root_path
    end
  end

  def destroy
    @publication = current_user.all_publications.find_by_id(params[:id])
    if @publication
      @publication.destroy
      redirect_to publications_path
    else
      redirect_to root_path
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
end
