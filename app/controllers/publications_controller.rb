class PublicationsController < ApplicationController
  before_filter :authenticate_user!

  def send_reminder
    @publication = Publication.current.find_by_id(params[:id])
    reviewer = User.current.find_by_id(params[:reviewer_id])
    if @publication and reviewer and (current_user.pp_committee_secretary? or current_user.steering_committee_secretary?)
      UserMailer.publication_approval_reminder(@publication, reviewer).deliver
      render :update do |page|
        page.replace_html "user_#{reviewer.id}_notified", '<span class="quiet">User Notified by Email</span>'
      end
    else
      render :nothing => true
    end
  end

  def edit_manuscript
    @publication = current_user.all_publications.find_by_id(params[:id])
    if @publication and ['nominated', 'submitted', 'published'].include?(@publication.status)
      render :update do |page|
        page.replace_html 'manuscript_container', :partial => 'publications/manuscripts/edit'
      end
    else
      render :nothing => true
    end
  end
  
  def show_manuscript
    @publication = current_user.all_viewable_publications.find_by_id(params[:id])
    if @publication and ['nominated', 'submitted', 'published'].include?(@publication.status)
      render :update do |page|
        page.replace_html 'manuscript_container', :partial => 'publications/manuscripts/show'
      end
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
      render :update do |page|
        page.replace_html 'manuscript_container', :partial => 'publications/manuscripts/edit'
      end
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
    if @publication and current_user.pp_committee_secretary?
      render :update do |page|
        page.replace_html 'subcommittee_decision_box', :partial => 'publications/show_subcommittee_decision'
      end
    else
      render :nothing => true
    end
  end
  
  def edit_subcommittee_decision
    @publication = Publication.current.find_by_id(params[:id])
    if @publication and current_user.pp_committee_secretary?
      render :update do |page|
        page.replace_html 'subcommittee_decision_box', :partial => 'publications/edit_subcommittee_decision'
      end
    else
      render :nothing => true
    end
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
    if @publication and current_user.steering_committee_secretary?
      render :update do |page|
        page.replace_html 'steering_committee_decision_box', :partial => 'publications/show_steering_committee_decision'
      end
    else
      render :nothing => true
    end
  end
  
  def edit_steering_committee_decision
    @publication = Publication.current.find_by_id(params[:id])
    if @publication and current_user.steering_committee_secretary?
      render :update do |page|
        page.replace_html 'steering_committee_decision_box', :partial => 'publications/edit_steering_committee_decision'
      end
    else
      render :nothing => true
    end
  end

  def index
    @publications = current_user.all_viewable_publications
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
    if current_user.pp_committee_secretary? or current_user.steering_committee_secretary?
      @publication = Publication.current.find_by_id(params[:id])
    end
    
    if @publication
      render :update do |page|
        page.replace_html "publication_#{@publication.id}_container", :partial => "publications/inline_edit"
      end
    else
      render :nothing => true
    end
  end
  
  def inline_update
    if current_user.pp_committee_secretary? or current_user.steering_committee_secretary?
      @publication = Publication.current.find_by_id(params[:id])
    end
    
    if @publication and params[:publication][params[:id]]
      [:manuscript_number, :secretary_notes, :status].each do |attribute|
        @publication.update_attribute attribute, params[:publication][params[:id]][attribute]
      end
      
      day = params[:publication][params[:id]][:targeted_start_date]
      @publication.update_attribute :targeted_start_date, Date.parse([day['(1i)'], day['(2i)'], day['(3i)']].join('.'))
      
      render :update do |page|
        page.replace_html "publication_#{@publication.id}_container", :partial => "publications/inline_show"
      end
    else
      render :nothing => true
    end    
  end
  
  def inline_show
    if current_user.pp_committee_secretary? or current_user.steering_committee_secretary?
      @publication = Publication.current.find_by_id(params[:id])
    end
    
    if @publication
      render :update do |page|
        page.replace_html "publication_#{@publication.id}_container", :partial => "publications/inline_show"
      end
    else
      render :nothing => true
    end
  end

  def create
    @publication = current_user.publications.new(params[:publication])
    @publication.author_assurance_date = Date.today
    if @publication.save
      @publication.update_attribute :status, 'draft'
      redirect_to(@publication, :notice => 'Publication was successfully created.')
    else
      flash[:alert] = "#{@publication.errors.count} error#{ 's' unless @publication.errors.count == 1} prohibited this publication from being saved." if @publication.errors.any?
      render :action => "new"
    end
  end

  def update
    @publication = current_user.all_publications.find_by_id(params[:id])
    if @publication and ['draft', 'not approved'].include?(@publication.status)
      if @publication.update_attributes(params[:publication])
        @publication.update_attribute :status, params[:publish] == '1' ? 'proposed' : 'draft'
        redirect_to(@publication, :notice => params[:publish] == '1' ? 'Publication was successfully resubmitted for review.' : 'Draft was saved successfully.')
      else
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
