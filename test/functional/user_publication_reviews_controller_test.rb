require 'test_helper'

class UserPublicationReviewsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @user_publication_review = user_publication_reviews(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_publication_reviews)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_publication_review" do
    assert_difference('UserPublicationReview.count') do
      post :create, :user_publication_review => @user_publication_review.attributes
    end

    assert_redirected_to user_publication_review_path(assigns(:user_publication_review))
  end

  test "should show user_publication_review" do
    get :show, :id => @user_publication_review.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @user_publication_review.to_param
    assert_response :success
  end

  test "should update user_publication_review" do
    put :update, :id => @user_publication_review.to_param, :user_publication_review => @user_publication_review.attributes
    assert_redirected_to user_publication_review_path(assigns(:user_publication_review))
  end

  test "should destroy user_publication_review" do
    assert_difference('UserPublicationReview.count', -1) do
      delete :destroy, :id => @user_publication_review.to_param
    end

    assert_redirected_to user_publication_reviews_path
  end
end
