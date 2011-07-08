require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  tests Devise::RegistrationsController
  # include Devise::TestHelpers
  
  setup do
    login(users(:admin))
  end
  
  test "should create user" do
    assert_difference('User.count') do
      post :create, :user => {:first_name => 'First Name', :last_name => 'Last Name', :status => 'active', :steering_committee => true}
    end
  
    assert_redirected_to user_path(assigns(:user))
  end
end
