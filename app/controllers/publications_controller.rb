class PublicationsController < ApplicationController
  before_filter :authenticate_user!

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
      @publication.update_attributes(:manuscript => params[:publication][:manuscript], :manuscript_uploaded_at => Time.now)
      redirect_to @publication
    elsif @publication
      redirect_to @publication, :notice => 'Please specify a file to upload.'
    else
      redirect_to root_path
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

  def create
    @publication = current_user.publications.new(params[:publication])
    @publication.author_assurance_date = Date.today
    if @publication.save
      @publication.update_attribute :status, 'draft'
      redirect_to(@publication, :notice => 'Publication was successfully created.')
    else
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
