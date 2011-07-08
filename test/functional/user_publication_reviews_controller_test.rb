require 'test_helper'

class UserPublicationReviewsControllerTest < ActionController::TestCase
  setup do
    login(users(:pp_committee))
    @user_publication_review = user_publication_reviews(:one)
  end

  # TODO: Update or remove
  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:user_publication_reviews)
  # end

  test "should get new" do
    get :new, :format => 'js'
    assigns(:user_publication_review)
    assert_template 'new'
  end

  test "should create user_publication_review" do
    assert_difference('UserPublicationReview.count') do
      post :create, :user_publication_review => @user_publication_review.attributes, :publication_id => 3, :format => 'js'
    end

    assigns(:user_publication_review)
    assert_template 'show'
  end

  test "should show user_publication_review" do
    get :show, :id => @user_publication_review.to_param, :format => 'js'
    assigns(:user_publication_review)
    assert_template 'show'
  end

  test "should get edit" do
    get :edit, :id => @user_publication_review.to_param, :format => 'js'
    assigns(:user_publication_review)
    assert_template 'new'
  end

  test "should update user_publication_review" do
    put :update, :id => @user_publication_review.to_param, :user_publication_review => @user_publication_review.attributes, :format => 'js'
    assigns(:user_publication_review)
    assert_template 'show'
  end

  # TODO: Update or remove
  # test "should destroy user_publication_review" do
  #   assert_difference('UserPublicationReview.count', -1) do
  #     delete :destroy, :id => @user_publication_review.to_param
  #   end
  # 
  #   assert_redirected_to user_publication_reviews_path
  # end
end
