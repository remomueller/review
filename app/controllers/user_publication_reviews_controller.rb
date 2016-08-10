# frozen_string_literal: true

# Allows reviews to be made for publications
class UserPublicationReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_upr, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_upr, only: [ :show, :edit, :update, :destroy ]

  def show
  end

  def new
    @user_publication_review = current_user.user_publication_reviews.find_by_publication_id(params[:publication_id]) #UserPublicationReview.new
    @user_publication_review = current_user.user_publication_reviews.new(publication_id: params[:publication_id]) unless @user_publication_review
  end

  def edit
    @publication = @user_publication_review.publication
    if @publication and @publication.reviewable?(current_user)
      render 'new'
    else
      head :ok
    end
  end

  def create
    if current_user.committee_member?
      @publication = Publication.current.find_by_id(params[:publication_id])
      @user_publication_review = current_user.user_publication_reviews.where( publication_id: @publication.id ).first_or_create if @publication
      if @publication and @publication.reviewable?(current_user) and @user_publication_review.update(upr_params) # @user_publication_review.save
        render 'show'
      else
        head :ok
      end
    else
      head :ok
    end
  end

  def update
    @publication = @user_publication_review.publication
    if @publication and @publication.reviewable?(current_user) and @user_publication_review.update(upr_params)
      render 'show'
    else
      head :ok
    end
  end

  private

    def set_upr
      @user_publication_review = current_user.user_publication_reviews.find_by_id(params[:id])
    end

    def redirect_without_upr
      empty_response_or_root_path(publications_path) unless @user_publication_review
    end

    def upr_params
      params.require(:user_publication_review).permit(
        :status, :comment, :writing_group_nomination
      )
    end

end
