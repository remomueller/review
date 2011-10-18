class PublicationsController < ApplicationController
  before_filter :authenticate_user!

  def tag_for_review
    @committee = params[:committee]
    @publication = Publication.current.find_by_id(params[:id])
    if @publication and current_user.pp_committee_secretary? and params[:committee] == 'pp'
      @publication.update_attribute :tagged_for_pp_review, (params[:tagged] == '1')
    elsif @publication and current_user.steering_committee_secretary? and params[:committee] == 'sc'
      @publication.update_attribute :tagged_for_sc_review, (params[:tagged] == '1')
    else
      render :nothing => true
    end    
  end

  def send_reminder
    @publication = Publication.current.find_by_id(params[:id])
    @reviewer = User.current.find_by_id(params[:reviewer_id])
    if @publication and @reviewer and current_user.secretary?
      
      @user_publication_review = @reviewer.user_publication_reviews.find_by_publication_id(@publication.id)
      @user_publication_review = @reviewer.user_publication_reviews.create(:publication_id => @publication.id) if @user_publication_review.blank?
      
      @user_publication_review.update_attribute :reminder_sent_at, Time.now
      
      UserMailer.publication_approval_reminder(@publication, @reviewer).deliver if Rails.env.production?
    else
      render :nothing => true
    end
  end

  def edit_manuscript
    @publication = current_user.secretary? ? Publication.current.find_by_id(params[:id]) : current_user.all_publications.find_by_id(params[:id])
    if @publication and ['nominated', 'submitted', 'published'].include?(@publication.status)
      render 'publications/manuscripts/edit_manuscript'
    else
      render :nothing => true
    end
  end
  
  def show_manuscript
    @publication = current_user.all_viewable_publications.find_by_id(params[:id])
    if @publication and ['nominated', 'submitted', 'published'].include?(@publication.status)
      render 'publications/manuscripts/show_manuscript'
    else
      render :nothing => true
    end
  end

  # Unfortunately a Remote Multipart Form submission isn't a built-in HTML feature...
  def upload_manuscript
    @publication = current_user.secretary? ? Publication.current.find_by_id(params[:id]) : current_user.all_publications.find_by_id(params[:id])
    if @publication and ['nominated', 'submitted', 'published'].include?(@publication.status) and params[:publication] and params[:publication][:manuscript]
      # Remove any existing manuscripts!
      @publication.remove_manuscript!
      
      @publication.update_attributes(:manuscript => params[:publication][:manuscript], :manuscript_uploaded_at => Time.now)
      extension = params[:publication][:manuscript].original_filename.downcase.split('.').last
      message = ManuscriptUploader.new.extension_white_list.include?(extension) ? nil : "Not a valid document type: #{extension}"
      redirect_to @publication, :alert => message
      # render 'publications/manuscripts/show_manuscript'
    elsif @publication
      redirect_to @publication, :notice => 'Please specify a file to upload.'
      # render 'publications/manuscripts/edit_manuscript'
    else
      redirect_to root_path
      # render :nothing => true
    end
  end
  
  def destroy_manuscript
    @publication = current_user.secretary? ? Publication.current.find_by_id(params[:id]) : current_user.all_publications.find_by_id(params[:id])
    if @publication
      @publication.remove_manuscript!
      @publication.update_attribute :remove_manuscript, true
      render 'publications/manuscripts/edit_manuscript'
    else
      render :nothing => true
    end
  end

  def pp_approval
    @publication = Publication.current.find_by_id(params[:id])
    if @publication and current_user.pp_committee_secretary? and params[:publication]
      [:status, :manuscript_number, :additional_ppcommittee_instructions].each do |attribute|
        @publication.update_attribute attribute, params[:publication][attribute]
      end
      UserMailer.publication_approval(@publication, true, current_user).deliver if @publication.status != 'proposed' and @publication.user and Rails.env.production?
      @publication.send_reminders if @publication.status == 'approved'
      redirect_to @publication
    else
      redirect_to root_path
    end
  end

  def show_subcommittee_decision
    @publication = Publication.current.find_by_id(params[:id])
    render :nothing => true unless @publication and current_user.pp_committee_secretary?
  end
  
  def edit_subcommittee_decision
    @publication = Publication.current.find_by_id(params[:id])
    render :nothing => true unless @publication and current_user.pp_committee_secretary?
  end

  def sc_approval
    @publication = Publication.current.find_by_id(params[:id])
    if @publication and current_user.steering_committee_secretary? and params[:publication]
      [:status, :additional_sccommittee_instructions].each do |attribute|
        @publication.update_attribute attribute, params[:publication][attribute]
      end
      UserMailer.publication_approval(@publication, false, current_user).deliver if @publication.status != 'approved' and @publication.user and Rails.env.production?
      redirect_to @publication
    else
      redirect_to root_path
    end
  end

  def show_steering_committee_decision
    @publication = Publication.current.find_by_id(params[:id])
    render :nothing => true unless @publication and current_user.steering_committee_secretary?
  end
  
  def edit_steering_committee_decision
    @publication = Publication.current.find_by_id(params[:id])
    render :nothing => true unless @publication and current_user.steering_committee_secretary?
  end

  def index
  	first_visit = params[:order].blank?
    @order = ['tagged_for_pp_review', 'tagged_for_sc_review', 'manuscript_number', 'abbreviated_title', 'status', 'publication_type', 'targeted_start_date'].include?(params[:order].to_s.split(' ').first) ? params[:order] : 'manuscript_number DESC'

    publications_scope = current_user.all_viewable_publications
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| publications_scope = publications_scope.search(search_term) }
    
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
    redirect_to root_path unless @publication and ['draft', 'not approved'].include?(@publication.status)
  end
  
  def inline_edit
    @publication = Publication.current.find_by_id(params[:id]) if current_user.pp_committee_secretary? or current_user.steering_committee_secretary?
    render :nothing => true unless @publication
  end
  
  def inline_update
    if current_user.secretary?
      @publication = Publication.current.find_by_id(params[:id])
    end
    
    if @publication and params[:publication][params[:id]]
      
      params[:publication][params[:id]][:targeted_start_date] = Date.strptime(params[:publication][params[:id]][:targeted_start_date], "%m/%d/%Y") unless params[:publication][params[:id]][:targeted_start_date].blank?
      
      params[:publication][params[:id]].keys.each do |attribute|
        @publication.update_attribute attribute, params[:publication][params[:id]][attribute]
      end
      
      # begin
      #   @publication.update_attribute :targeted_start_date, Date.parse(params[:publication][params[:id]][:targeted_start_date])
      # rescue ArgumentError
      #   @publication.update_attribute :targeted_start_date, nil  
      # end
      
      render 'inline_show'
    else
      render :nothing => true
    end    
  end
  
  def inline_show
    if current_user.secretary?
      @publication = Publication.current.find_by_id(params[:id])
    end
    
    if @publication
      render 'inline_show'
    else
      render :nothing => true
    end
  end

  def create
    params[:publication][:status] = (params[:publish] == '1') ? 'proposed' : 'draft'
    params[:publication][:author_assurance_date] = Date.today if params[:publish] == '1'
    @publication = current_user.publications.new(params[:publication])
    
    # @publication.remove_manuscript!
    
    # @publication.update_attributes(:manuscript => params[:publication][:manuscript], :manuscript_uploaded_at => Time.now)
    # extension = params[:publication][:manuscript].original_filename.downcase.split('.').last
    # message = ManuscriptUploader.new.extension_white_list.include?(extension) ? nil : "Not a valid document type: #{extension}"
    
    
    if @publication.save
      @publication.update_attribute :status, params[:publish] == '1' ? 'proposed' : 'draft'
      @publication.send_reminders if params[:publish] == '1'
      if params[:publish] == '-1'
        flash[:notice] = "Publication draft was successfully quick saved."
        render :action => "new"
      else
        redirect_to(@publication, :notice => params[:publish] == '1' ? 'Publication was successfully submitted for review.' : 'Publication draft was successfully created.')
      end
    else
      flash[:alert] = "#{@publication.errors.count} error#{ 's' unless @publication.errors.count == 1} prohibited this publication from being saved." if @publication.errors.any?
      render :action => "new"
    end
  end

  def update
    @publication = current_user.all_publications.find_by_id(params[:id])
    if @publication and ['draft', 'not approved'].include?(@publication.status)
      params[:publication][:status] = (params[:publish] == '1') ? 'proposed' : 'draft'
      params[:publication][:author_assurance_date] = Date.today if params[:publish] == '1'
      if @publication.update_attributes(params[:publication])
        @publication.update_attribute :status, params[:publish] == '1' ? 'proposed' : 'draft'
        @publication.send_reminders if params[:publish] == '1'
        if params[:publish] == '-1'
          flash[:notice] = "Publication draft was successfully quick saved."
          render :action => "edit"
        else
          redirect_to(@publication, :notice => params[:publish] == '1' ? 'Publication was successfully resubmitted for review.' : 'Publication draft was saved successfully.')
        end
      else
        flash[:alert] = "#{@publication.errors.count} error#{ 's' unless @publication.errors.count == 1} prohibited this publication from being updated." if @publication.errors.any?
        render :action => "edit"
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
end
