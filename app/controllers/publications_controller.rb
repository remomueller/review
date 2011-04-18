class PublicationsController < ApplicationController
  before_filter :authenticate_user!

  def important
    @publication = Publication.current.find_by_id(params[:id])
    if @publication and (current_user.pp_committee_secretary? or current_user.steering_committee_secretary?)
      @publication.update_attribute :important, (params[:important] == '1')
    else
      render :nothing => true
    end
  end

  def send_reminder
    @publication = Publication.current.find_by_id(params[:id])
    @reviewer = User.current.find_by_id(params[:reviewer_id])
    if @publication and @reviewer and (current_user.pp_committee_secretary? or current_user.steering_committee_secretary?)
      UserMailer.publication_approval_reminder(@publication, @reviewer).deliver
    else
      render :nothing => true
    end
  end

  def edit_manuscript
    @publication = current_user.all_publications.find_by_id(params[:id])
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

  def upload_manuscript
    @publication = current_user.all_publications.find_by_id(params[:id])
    if @publication and ['nominated', 'submitted', 'published'].include?(@publication.status) and params[:publication] and params[:publication][:manuscript]
      # Remove any existing manuscripts!
      @publication.remove_manuscript!
      
      @publication.update_attributes(:manuscript => params[:publication][:manuscript], :manuscript_uploaded_at => Time.now)
      extension = params[:publication][:manuscript].original_filename.downcase.split('.').last
      message = ManuscriptUploader.new.extension_white_list.include?(extension) ? nil : "Not a valid document type: #{extension}"
      redirect_to @publication, :alert => message
    elsif @publication
      redirect_to @publication, :notice => 'Please specify a file to upload.'
    else
      redirect_to root_path
    end
  end
  
  def destroy_manuscript
    @publication = current_user.all_publications.find_by_id(params[:id])
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
      [:status, :manuscript_number].each do |attribute|
        @publication.update_attribute attribute, params[:publication][attribute]
      end
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
      [:status].each do |attribute|
        @publication.update_attribute attribute, params[:publication][attribute]
      end
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
    # @publications = current_user.all_viewable_publications.order('manuscript_number DESC, abbreviated_title')
    @order = ['manuscript_number', 'abbreviated_title', 'status'].include?(params[:order].to_s.split(' ').first) ? params[:order] : 'manuscript_number DESC'
    # @order = params[:order].blank? ? 'manuscript_number' : params[:order]
    logger.debug "ORDER: #{@order}"
    
    publications_scope = current_user.all_viewable_publications #.order('manuscript_number DESC, abbreviated_title')
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| publications_scope = publications_scope.search(search_term) }
    publications_scope = publications_scope.order('(important = 1) DESC, ' + @order)
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
    if current_user.pp_committee_secretary? or current_user.steering_committee_secretary?
      @publication = Publication.current.find_by_id(params[:id])
    end
    
    if @publication and params[:publication][params[:id]]
      [:user_id, :co_lead_author_id, :manuscript_number, :secretary_notes, :status, :dataset_requested_analyst].each do |attribute|
        @publication.update_attribute attribute, params[:publication][params[:id]][attribute]
      end
      
      begin
        @publication.update_attribute :targeted_start_date, Date.parse(params[:publication][params[:id]][:targeted_start_date])
      rescue ArgumentError
        @publication.update_attribute :targeted_start_date, nil  
      end
      
      render 'inline_show'
    else
      render :nothing => true
    end    
  end
  
  def inline_show
    if current_user.pp_committee_secretary? or current_user.steering_committee_secretary?
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
      redirect_to(@publication, :notice => params[:publish] == '1' ? 'Publication was successfully submitted for review.' : 'Publication draft was successfully created.')
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
        redirect_to(@publication, :notice => params[:publish] == '1' ? 'Publication was successfully resubmitted for review.' : 'Publication draft was saved successfully.')
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
