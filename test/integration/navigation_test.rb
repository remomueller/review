require 'test_helper'

SimpleCov.command_name 'test:integration'

class NavigationTest < ActionDispatch::IntegrationTest
  fixtures :users

  def setup
    @valid = users(:valid)
    @pending = users(:pending)
    @deleted = users(:deleted)
  end

  test 'pending users should be not be allowed to login' do
    get '/publications'
    assert_redirected_to new_user_session_path

    sign_in_as(@pending, '123456')
    assert_equal new_user_session_path, path
    assert_equal I18n.t('devise.failure.inactive'), flash[:alert]
  end

  test 'deleted users should be not be allowed to login' do
    get '/publications'
    assert_redirected_to new_user_session_path

    sign_in_as(@deleted, '123456')
    assert_equal new_user_session_path, path
    assert_equal I18n.t('devise.failure.inactive'), flash[:alert]
  end

  test 'root navigation redirected to login page' do
    get '/'
    assert_redirected_to new_user_session_path
    assert_equal I18n.t('devise.failure.unauthenticated'), flash[:alert]
  end

  test 'friendly url forwarding after login' do
    get '/publications'
    assert_redirected_to new_user_session_path

    sign_in_as(@valid, '123456')
    assert_equal '/publications', path
  end
end
