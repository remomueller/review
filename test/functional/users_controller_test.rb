require 'test_helper'

SimpleCov.command_name "test:functionals"

class UsersControllerTest < ActionController::TestCase
  setup do
    login(users(:admin))
    @user = users(:valid)
  end
  
  # test "should update settings and enable email" do
  #   post :update_settings, id: users(:admin).to_param, email: { send_email: '1' }
  #   users(:admin).reload # Needs reload to avoid stale object
  #   assert_equal true, users(:admin).email_on?(:send_email)
  #   assert_equal 'Email settings saved.', flash[:notice]
  #   assert_redirected_to settings_path
  # end
  # 
  # test "should update settings and disable email" do
  #   post :update_settings, id: users(:admin).to_param, email: { send_email: '0' }
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
  
  test "should get index with pagination" do
    get :index, format: 'js'
    assert_not_nil assigns(:users)
    assert_template 'index'
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
  
  test "should get index with pagination for non-system admin" do
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

  test "should show user" do
    get :show, id: @user.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user.to_param
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user.to_param, user: @user.attributes
    assert_redirected_to user_path(assigns(:user))
  end

  test "should not update user with blank name" do
    put :update, id: @user.to_param, user: { first_name: '', last_name: '' }
    assert_not_nil assigns(:user)
    assert_template 'edit'
  end

  test "should destroy user" do
    assert_difference('User.current.count', -1) do
      delete :destroy, id: @user.to_param
    end

    assert_redirected_to users_path
  end
end
