class UserPublicationReviewsController < ApplicationController
  before_filter :authenticate_user!
  
  # # GET /user_publication_reviews
  # # GET /user_publication_reviews.xml
  # def index
  #   @user_publication_reviews = UserPublicationReview.all
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @user_publication_reviews }
  #   end
  # end
  # 
  # # GET /user_publication_reviews/1
  # # GET /user_publication_reviews/1.xml
  def show
    @user_publication_review = current_user.user_publication_reviews.find_by_id(params[:id])
    unless @user_publication_review
      render :nothing => true
    end
  end
  # 
  # # GET /user_publication_reviews/new
  # # GET /user_publication_reviews/new.xml
  def new
    @user_publication_review = current_user.user_publication_reviews.find_by_publication_id(params[:publication_id]) #UserPublicationReview.new
    @user_publication_review = current_user.user_publication_reviews.new(:publication_id => params[:publication_id]) unless @user_publication_review
  end

  def edit
    @user_publication_review = current_user.user_publication_reviews.find_by_id(params[:id])
    if @user_publication_review and ((current_user.steering_committee? and @user_publication_review.publication.status == 'approved') or (current_user.pp_committee? and @user_publication_review.publication.status == 'proposed'))
      render 'new'
    else
      render :nothing => true
    end
  end
  
  def create
    if current_user.pp_committee? or current_user.steering_committee?
      @user_publication_review = current_user.user_publication_reviews.find_or_create_by_publication_id(params[:publication_id])
      # @user_publication_review = current_user.user_publication_reviews.new(params[:user_publication_review])
      if ((current_user.pp_committee? and @user_publication_review.publication.status == 'proposed') or (current_user.steering_committee? and @user_publication_review.publication.status == 'approved')) and @user_publication_review.update_attributes(params[:user_publication_review]) # @user_publication_review.save
        render 'show'
      else
        render :nothing => true
      end
    else
      render :nothing => true
    end
  end
  
  def update
    @user_publication_review = current_user.user_publication_reviews.find_by_id(params[:id])
    
    if @user_publication_review and ((current_user.steering_committee? and @user_publication_review.publication.status == 'approved') or (current_user.pp_committee? and @user_publication_review.publication.status == 'proposed'))
  
      if @user_publication_review.update_attributes(params[:user_publication_review])
        render 'show'
      else
        render :nothing => true
      end
    else
      # redirect_to(root_path, :warn => 'You do not have the privilege to update the selected publication review.')
      render :nothing => true
    end
  end
  # 
  # # DELETE /user_publication_reviews/1
  # # DELETE /user_publication_reviews/1.xml
  # def destroy
  #   @user_publication_review = UserPublicationReview.find(params[:id])
  #   @user_publication_review.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(user_publication_reviews_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
