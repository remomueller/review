# frozen_string_literal: true

require 'test_helper'

SimpleCov.command_name 'test:models'

# Unit tests for user model
class UserTest < ActiveSupport::TestCase
  test 'should get reverse name' do
    assert_equal 'LastName, FirstName', users(:valid).reverse_name
  end
end
