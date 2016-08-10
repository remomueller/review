# frozen_string_literal: true

require 'test_helper'

# Test to assure public pages can be displayed.
class ApplicationControllerTest < ActionController::TestCase
  test 'should get about' do
    get :about
    assert_response :success
  end

  test 'should get version' do
    get :version
    assert_response :success
  end

  test 'should get version as json' do
    get :version, format: 'json'
    version = JSON.parse(response.body)
    assert_equal Review::VERSION::STRING, version['version']['string']
    assert_equal Review::VERSION::MAJOR, version['version']['major']
    assert_equal Review::VERSION::MINOR, version['version']['minor']
    assert_equal Review::VERSION::TINY, version['version']['tiny']
    assert_equal Review::VERSION::BUILD, version['version']['build']
    assert_response :success
  end
end
