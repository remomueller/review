# frozen_string_literal: true

require 'test_helper'

# Test to assure committee members can review publications.
class UserPublicationReviewsControllerTest < ActionController::TestCase
  setup do
    login(users(:pp_committee))
    @user_publication_review = user_publication_reviews(:one)
  end

  test 'should get new' do
    get :new, xhr: true, format: 'js'
    assert_not_nil assigns(:user_publication_review)
    assert_template 'new'
  end

  test 'should create user publication review' do
    assert_difference('UserPublicationReview.count') do
      post :create, params: {
        user_publication_review: @user_publication_review.attributes, publication_id: publications(:three).to_param
      }, format: 'js'
    end

    assert_not_nil assigns(:user_publication_review)
    assert_template 'show'
  end

  test 'should create user publication review and send notification to secretary' do
    login(users(:sc_committee))
    assert_difference('UserPublicationReview.count') do
      post :create, params: {
        user_publication_review: { comment: 'I reviewed this.', writing_group_nomination: 'Jane Smith, Bill Smith', status: 'approved' }, publication_id: publications(:nominated).to_param
      }, format: 'js'
    end

    assert_not_nil assigns(:user_publication_review)
    assert_template 'show'
  end

  test 'should not create user publication review for invalid publication' do
    assert_difference('UserPublicationReview.count', 0) do
      post :create, params: {
        user_publication_review: @user_publication_review.attributes, publication_id: -1
      }, format: 'js'
    end

    assert_nil assigns(:publication)
    assert_nil assigns(:user_publication_review)
    assert_response :success
  end

  test 'should not create user publication review for non-committee member' do
    login(users(:valid))
    assert_difference('UserPublicationReview.count', 0) do
      post :create, params: {
        user_publication_review: @user_publication_review.attributes, publication_id: publications(:three).to_param
      }, format: 'js'
    end

    assert_nil assigns(:user_publication_review)
    assert_response :success
  end

  test 'should show user publication review' do
    get :show, params: {
      id: @user_publication_review.to_param
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:user_publication_review)
    assert_template 'show'
  end

  test 'should not show user publication review with invalid id' do
    get :show, params: {
      id: -1
    }, format: 'js'
    assert_nil assigns(:user_publication_review)
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: {
      id: @user_publication_review.to_param
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:user_publication_review)
    assert_template 'new'
  end

  test 'should not get edit with invalid id' do
    get :edit, params: {
      id: -1
    }, format: 'js'
    assert_nil assigns(:user_publication_review)
    assert_response :success
  end

  test 'should update user publication review' do
    patch :update, params: {
      id: @user_publication_review.to_param, user_publication_review: @user_publication_review.attributes
    }, format: 'js'
    assert_not_nil assigns(:user_publication_review)
    assert_template 'show'
  end

  test 'should not update user publication review with invalid id' do
    patch :update, params: {
      id: -1, :user_publication_review => @user_publication_review.attributes
    }, format: 'js'
    assert_nil assigns(:user_publication_review)
    assert_response :success
  end
end
