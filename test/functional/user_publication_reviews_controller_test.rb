require 'test_helper'

class UserPublicationReviewsControllerTest < ActionController::TestCase
  setup do
    login(users(:pp_committee))
    @user_publication_review = user_publication_reviews(:one)
  end

  test "should get new" do
    get :new, format: 'js'
    assert_not_nil assigns(:user_publication_review)
    assert_template 'new'
  end

  test "should create user publication review" do
    assert_difference('UserPublicationReview.count') do
      post :create, user_publication_review: @user_publication_review.attributes, publication_id: 3, format: 'js'
    end

    assert_not_nil assigns(:user_publication_review)
    assert_template 'show'
  end

  test "should not create user publication review for invalid publication" do
    assert_difference('UserPublicationReview.count', 0) do
      post :create, user_publication_review: @user_publication_review.attributes, publication_id: -1, format: 'js'
    end

    assert_nil assigns(:publication)
    assert_nil assigns(:user_publication_review)
    assert_response :success
  end

  test "should not create user publication review for non-committee member" do
    login(users(:valid))
    assert_difference('UserPublicationReview.count', 0) do
      post :create, user_publication_review: @user_publication_review.attributes, publication_id: 3, format: 'js'
    end

    assert_nil assigns(:user_publication_review)
    assert_response :success
  end

  test "should show user publication review" do
    get :show, id: @user_publication_review.to_param, format: 'js'
    assert_not_nil assigns(:user_publication_review)
    assert_template 'show'
  end

  test "should not show user publication review with invalid id" do
    get :show, id: -1, format: 'js'
    assert_nil assigns(:user_publication_review)
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_publication_review.to_param, format: 'js'
    assert_not_nil assigns(:user_publication_review)
    assert_template 'new'
  end

  test "should not get edit with invalid id" do
    get :edit, id: -1, format: 'js'
    assert_nil assigns(:user_publication_review)
    assert_response :success
  end

  test "should update user publication review" do
    put :update, id: @user_publication_review.to_param, user_publication_review: @user_publication_review.attributes, format: 'js'
    assert_not_nil assigns(:user_publication_review)
    assert_template 'show'
  end

  test "should not update user publication review with invalid id" do
    put :update, id: -1, :user_publication_review => @user_publication_review.attributes, format: 'js'
    assert_nil assigns(:user_publication_review)
    assert_response :success
  end
end
