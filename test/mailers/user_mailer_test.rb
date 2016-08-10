# frozen_string_literal: true

require 'test_helper'

# Tests that mail views are rendered corretly, sent to correct user, and have a
# correct subject line
class UserMailerTest < ActionMailer::TestCase
  test 'notify system admin email' do
    valid = users(:valid)
    admin = users(:admin)
    mail = UserMailer.notify_system_admin(admin, valid)
    assert_equal [admin.email], mail.to
    assert_equal "#{valid.name} Signed Up", mail.subject
    assert_match(/#{valid.name} \[#{valid.email}\] signed up for an account\./, mail.body.encoded)
  end

  test 'status activated email' do
    valid = users(:valid)
    mail = UserMailer.status_activated(valid)
    assert_equal [valid.email], mail.to
    assert_equal "#{valid.name}'s Account Activated", mail.subject
    assert_match(/Your account \[#{valid.email}\] has been activated\./, mail.body.encoded)
  end

  test 'review updated email' do
    secretary = users(:pp_secretary)
    upr = user_publication_reviews(:one)
    mail = UserMailer.review_updated(upr, secretary)
    assert_equal [secretary.email], mail.to
    assert_equal "#{upr.user.name} has reviewed #{upr.publication.abbreviated_title_and_ms}", mail.subject
    assert_match(/#{upr.user.name} \[#{upr.user.email}\] has created or updated a review for:/, mail.body.encoded)
  end

  test 'publication approval reminder email' do
    valid = users(:valid)
    mail = UserMailer.publication_approval_reminder(
      valid,
      'recipient@example.com', 'cc@example.com', 'New Publication Awaiting Approval',
      'Body'
    )
    assert_equal ['recipient@example.com'], mail.to
    assert_equal 'New Publication Awaiting Approval', mail.subject
    assert_match(/Body/, mail.body.encoded)
  end

  test 'publication approval email for P&P approved publication' do
    publication = publications(:proposed)
    secretary = users(:pp_secretary)
    publication.status = 'approved'
    mail = UserMailer.publication_approval(publication, true, secretary)
    assert_equal [publication.user.email], mail.to
    assert_equal(
      "Publication Proposal for #{publication.abbreviated_title_and_ms} has been approved by the P&P Committee",
      mail.subject
    )
    assert_match(
      /Your publication proposal #{publication.full_title_and_ms} has been approved by the P&P Committee\./,
      mail.body.encoded
    )
  end

  test 'publication approval email for P&P denied publication' do
    publication = publications(:proposed)
    secretary = users(:pp_secretary)
    publication.status = 'not approved'
    mail = UserMailer.publication_approval(publication, true, secretary)
    assert_equal [publication.user.email], mail.to
    assert_equal(
      "Publication Proposal for #{publication.abbreviated_title_and_ms} has been denied by the P&P Committee",
      mail.subject
    )
    assert_match(
      /Your publication proposal #{publication.full_title_and_ms} has been denied by the P&P Committee\./,
      mail.body.encoded
    )
  end

  test 'publication approval email for SC approved publication' do
    publication = publications(:proposed)
    secretary = users(:sc_secretary)
    publication.status = 'nominated'
    mail = UserMailer.publication_approval(publication, false, secretary)
    assert_equal [publication.user.email], mail.to
    assert_equal(
      "Publication Proposal for #{publication.abbreviated_title_and_ms} has been approved by the Steering Committee",
      mail.subject
    )
    assert_match(
      /Your publication proposal #{publication.full_title_and_ms} has been approved by the Steering Committee\./,
      mail.body.encoded
    )
  end

  test 'publication approval email for SC denied publication' do
    publication = publications(:proposed)
    secretary = users(:sc_secretary)
    publication.status = 'not approved'
    mail = UserMailer.publication_approval(publication, false, secretary)
    assert_equal [publication.user.email], mail.to
    assert_equal(
      "Publication Proposal for #{publication.abbreviated_title_and_ms} has been denied by the Steering Committee",
      mail.subject
    )
    assert_match(
      /Your publication proposal #{publication.full_title_and_ms} has been denied by the Steering Committee\./,
      mail.body.encoded
    )
  end
end
