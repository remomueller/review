require 'test_helper'

class PublicationTest < ActiveSupport::TestCase

  test "should show pretty targeted start date" do
    date = Date.today
    proposed = publications(:proposed)
    proposed.targeted_start_date = date
    assert_equal date.strftime('%b %d (%a)'), proposed.targeted_start_date_pretty
  end
  
  test "should show pretty targeted start date full date from last year" do
    date = Date.today - 1.year
    proposed = publications(:proposed)
    proposed.targeted_start_date = date
    assert_equal date.strftime('%b %d, %Y (%a)'), proposed.targeted_start_date_pretty
  end
  
  test "should show human status" do
    proposed = publications(:proposed)
    proposed.status = 'approved'
    assert_equal "P&P Approved", proposed.human_status
    proposed.status = ''
    assert_equal '', proposed.human_status
  end
  
end
