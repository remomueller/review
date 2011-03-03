class PublicationsController < ApplicationController
  before_filter :authenticate_user!

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

  def index
    @publications = current_user.all_publications
  end

  def show
    @publication = current_user.all_publications.find_by_id(params[:id])
    redirect_to root_path unless @publication
  end

  def new
    @publication = current_user.publications.new
  end

  def edit
    @publication = current_user.all_publications.find_by_id(params[:id])
    redirect_to root_path unless @publication and @publication.status == 'proposed'
  end

  def create
    @publication = current_user.publications.new(params[:publication])
    @publication.author_assurance_date = Date.today
    if @publication.save
      redirect_to(@publication, :notice => 'Publication was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @publication = current_user.all_publications.find_by_id(params[:id])
    if @publication
      if @publication.update_attributes(params[:publication])
        redirect_to(@publication, :notice => 'Publication was successfully updated.')
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
