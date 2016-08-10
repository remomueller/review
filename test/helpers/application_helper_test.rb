# frozen_string_literal: true

require 'test_helper'

SimpleCov.command_name 'test:helpers'

# Tests for application helper methods
class ApplicationHelperTest < ActionView::TestCase
  test 'should show time' do
    time = Time.zone.now
    assert_equal time.strftime('at %I:%M %p'), simple_time(time)
  end

  test 'should show full time from yesterday' do
    time = Time.zone.now - 1.day
    time += 2.days if time.year != Time.zone.now.year # Test would fail if run on Jan 1st otherwise
    assert_equal time.strftime('on %b %d at %I:%M %p'), simple_time(time)
  end

  test 'should show full time from last year' do
    time = Time.zone.now - 1.year
    assert_equal time.strftime('on %b %d, %Y at %I:%M %p'), simple_time(time)
  end

  test 'should display status' do
    assert display_status(nil).is_a?(String)
    assert display_status('').is_a?(String)
    assert display_status('published').is_a?(String)
    assert display_status('submitted').is_a?(String)
    assert display_status('nominated').is_a?(String)
    assert display_status('approved').is_a?(String)
    assert display_status('proposed').is_a?(String)
    assert display_status('draft').is_a?(String)
    assert display_status('not approved').is_a?(String)
  end
end
