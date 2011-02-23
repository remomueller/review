class PublicationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @publications = current_user.all_publications
  end

  def show
    @publication = current_user.all_publications.find(params[:id])
    redirect_to root_path unless @publication
  end

  def new
    @publication = current_user.publications.new
  end

  def edit
    @publication = current_user.all_publications.find(params[:id])
    redirect_to root_path unless @publication
  end

  def create
    @publication = current_user.publications.new(params[:publication])

    if @publication.save
      redirect_to(@publication, :notice => 'Publication was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @publication = current_user.all_publications.find(params[:id])
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
    @publication = current_user.all_publications.find(params[:id])
    if @publication
      @publication.destroy
      redirect_to publications_path
    else
      redirect_to root_path
    end
  end
end
