# frozen_string_literal: true

require 'test_helper'

SimpleCov.command_name "test:controllers"

class UsersControllerTest < ActionController::TestCase
  setup do
    login(users(:admin))
    @user = users(:valid)
  end

  # test "should update settings and enable email" do
  #   post :update_settings, id: users(:admin), email: { send_email: '1' }
  #   users(:admin).reload # Needs reload to avoid stale object
  #   assert_equal true, users(:admin).email_on?(:send_email)
  #   assert_equal 'Email settings saved.', flash[:notice]
  #   assert_redirected_to settings_path
  # end
  #
  # test "should update settings and disable email" do
  #   post :update_settings, id: users(:admin), email: { send_email: '0' }
  #   users(:admin).reload # Needs reload to avoid stale object
  #   assert_equal false, users(:admin).email_on?(:send_email)
  #   assert_equal 'Email settings saved.', flash[:notice]
  #   assert_redirected_to settings_path
  # end

  test "should get index" do
    get :index
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should get index for autocomplete" do
    login(users(:valid))
    get :index, format: 'json'
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should not get index for non-system admin" do
    login(users(:valid))
    get :index
    assert_nil assigns(:users)
    assert_equal "You do not have sufficient privileges to access that page.", flash[:alert]
    assert_redirected_to root_path
  end

  test "should not get index with pagination for non-system admin" do
    login(users(:valid))
    get :index, format: 'js'
    assert_nil assigns(:users)
    assert_equal "You do not have sufficient privileges to access that page.", flash[:alert]
    assert_redirected_to root_path
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  # This is the action that overwrites the default Contour user create action
  test "should activate user" do
    assert_difference('User.current.count') do
      post :activate, user: { first_name: 'First Name', last_name: 'Last Name', email: 'activated@example.com', status: 'active', pp_committee: true, pp_committee_secretary: true, steering_committee: true, steering_committee_secretary: true, system_admin: true }
    end

    assert_not_nil assigns(:user)
    assert_equal 'First Name', assigns(:user).first_name
    assert_equal 'Last Name', assigns(:user).last_name
    assert_equal 'activated@example.com', assigns(:user).email
    assert_equal 'active', assigns(:user).status
    assert_equal true, assigns(:user).pp_committee
    assert_equal true, assigns(:user).pp_committee_secretary
    assert_equal true, assigns(:user).steering_committee
    assert_equal true, assigns(:user).steering_committee_secretary
    assert_equal true, assigns(:user).system_admin

    assert_redirected_to assigns(:user)
  end

  test "should not activate user with blank name" do
    assert_difference('User.current.count', 0) do
      post :activate, user: { first_name: '', last_name: '', email: '', status: 'active' }
    end

    assert_not_nil assigns(:user)
    assert_equal ["can't be blank"], assigns(:user).errors[:first_name]
    assert_equal ["can't be blank"], assigns(:user).errors[:last_name]
    assert_equal ["can't be blank"], assigns(:user).errors[:email]
    assert_equal 3, assigns(:user).errors.size

    assert_template 'new'
    assert_response :success
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: { first_name: 'FirstName', last_name: 'LastName', email: 'valid_updated_email@example.com', status: 'active', system_admin: false }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should update user and set user active" do
    put :update, id: users(:pending), user: { status: 'active', first_name: users(:pending).first_name, last_name: users(:pending).last_name, email: users(:pending).email, system_admin: false }
    assert_equal 'active', assigns(:user).status
    assert_redirected_to user_path(assigns(:user))
  end

  test "should update user and set user inactive" do
    put :update, id: users(:pending), user: { status: 'inactive', first_name: users(:pending).first_name, last_name: users(:pending).last_name, email: users(:pending).email, system_admin: false }
    assert_equal 'inactive', assigns(:user).status
    assert_redirected_to user_path(assigns(:user))
  end

  test "should not update user with blank name" do
    put :update, id: @user, user: { first_name: '', last_name: '' }
    assert_not_nil assigns(:user)
    assert_template 'edit'
  end

  test "should not update user with invalid id" do
    put :update, id: -1, user: { first_name: 'FirstName', last_name: 'LastName', email: 'valid_updated_email@example.com', status: 'active', system_admin: false }
    assert_nil assigns(:user)
    assert_redirected_to users_path
  end

  test "should destroy user" do
    assert_difference('User.current.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
