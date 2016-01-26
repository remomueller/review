require 'test_helper'

SimpleCov.command_name "test:helpers"

class ApplicationHelperTest < ActionView::TestCase
  test "should show time" do
    time = Time.zone.now
    assert_equal time.strftime("at %I:%M %p"), simple_time(time)
  end

  test "should show full time from yesterday" do
    time = Time.zone.now - 1.day
    time += 2.days if time.year != Time.zone.now.year # Test would fail if run on Jan 1st otherwise
    assert_equal time.strftime("on %b %d at %I:%M %p"), simple_time(time)
  end

  test "should show full time from last year" do
    time = Time.zone.now - 1.year
    assert_equal time.strftime("on %b %d, %Y at %I:%M %p"), simple_time(time)
  end

  test "should show recent activity" do
    assert recent_activity(nil).kind_of?(String)
    assert recent_activity('').kind_of?(String)
    assert recent_activity(Time.zone.now).kind_of?(String)
    assert recent_activity(Time.zone.now - 12.hours).kind_of?(String)
    assert recent_activity(Time.zone.now - 1.day).kind_of?(String)
    assert recent_activity(Time.zone.now - 2.days).kind_of?(String)
    assert recent_activity(Time.zone.now - 1.week).kind_of?(String)
    assert recent_activity(Time.zone.now - 1.month).kind_of?(String)
    assert recent_activity(Time.zone.now - 6.month).kind_of?(String)
    assert recent_activity(Time.zone.now - 1.year).kind_of?(String)
    assert recent_activity(Time.zone.now - 2.year).kind_of?(String)
  end

  test "should display status" do
    assert display_status(nil).kind_of?(String)
    assert display_status('').kind_of?(String)
    assert display_status('published').kind_of?(String)
    assert display_status('submitted').kind_of?(String)
    assert display_status('nominated').kind_of?(String)
    assert display_status('approved').kind_of?(String)
    assert display_status('proposed').kind_of?(String)
    assert display_status('draft').kind_of?(String)
    assert display_status('not approved').kind_of?(String)
  end
end
