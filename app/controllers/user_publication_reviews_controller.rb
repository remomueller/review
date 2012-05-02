class UserPublicationReviewsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user_publication_review = current_user.user_publication_reviews.find_by_id(params[:id])
    render nothing: true unless @user_publication_review
  end

  def new
    @user_publication_review = current_user.user_publication_reviews.find_by_publication_id(params[:publication_id]) #UserPublicationReview.new
    @user_publication_review = current_user.user_publication_reviews.new(publication_id: params[:publication_id]) unless @user_publication_review
  end

  def edit
    @user_publication_review = current_user.user_publication_reviews.find_by_id(params[:id])
    @publication = @user_publication_review.publication if @user_publication_review
    if @user_publication_review and @publication and @publication.reviewable?(current_user)
      render 'new'
    else
      render nothing: true
    end
  end

  def create
    if current_user.committee_member?
      @publication = Publication.current.find_by_id(params[:publication_id])
      @user_publication_review = current_user.user_publication_reviews.find_or_create_by_publication_id(@publication.id) if @publication
      if @publication and @publication.reviewable?(current_user) and @user_publication_review.update_attributes(params[:user_publication_review]) # @user_publication_review.save
        render 'show'
      else
        render nothing: true
      end
    else
      render nothing: true
    end
  end

  def update
    @user_publication_review = current_user.user_publication_reviews.find_by_id(params[:id])
    @publication = @user_publication_review.publication if @user_publication_review
    if @publication and @publication.reviewable?(current_user) and @user_publication_review and @user_publication_review.update_attributes(params[:user_publication_review])
      render 'show'
    else
      # redirect_to(root_path, :warn => 'You do not have the privilege to update the selected publication review.')
      render nothing: true
    end
  end
end
