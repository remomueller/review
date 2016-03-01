# frozen_string_literal: true

require 'test_helper'

# Tests that mail views are rendered corretly, sent to correct user, and have a
# correct subject line
class UserMailerTest < ActionMailer::TestCase
  test 'notify system admin email' do
    valid = users(:valid)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.notify_system_admin(admin, valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [admin.email], email.to
    assert_equal "#{valid.name} Signed Up", email.subject
    assert_match(/#{valid.name} \[#{valid.email}\] signed up for an account\./, email.encoded)
  end

  test 'status activated email' do
    valid = users(:valid)
    # Send the email, then test that it got queued
    email = UserMailer.status_activated(valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [valid.email], email.to
    assert_equal "#{valid.name}'s Account Activated", email.subject
    assert_match(/Your account \[#{valid.email}\] has been activated\./, email.encoded)
  end

  test 'review updated email' do
    secretary = users(:pp_secretary)
    upr = user_publication_reviews(:one)

    # Send the email, then test that it got queued
    email = UserMailer.review_updated(upr, secretary).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [secretary.email], email.to
    assert_equal "#{upr.user.name} has reviewed #{upr.publication.abbreviated_title_and_ms}", email.subject
    assert_match(/#{upr.user.name} \[#{upr.user.email}\] has created or updated a review for:/, email.encoded)
  end

  test 'publication approval reminder email' do
    valid = users(:valid)

    # Send the email, then test that it got queued
    email = UserMailer.publication_approval_reminder(
      valid,
      'recipient@example.com', 'cc@example.com', 'New Publication Awaiting Approval',
      'Body'
    ).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ['recipient@example.com'], email.to
    assert_equal 'New Publication Awaiting Approval', email.subject
    assert_match(/Body/, email.encoded)
  end

  test 'publication approval email for P&P approved publication' do
    publication = publications(:proposed)
    secretary = users(:pp_secretary)
    publication.status = 'approved'

    email = UserMailer.publication_approval(publication, true, secretary).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [publication.user.email], email.to
    assert_equal(
      "Publication Proposal for #{publication.abbreviated_title_and_ms} has been approved by the P&P Committee",
      email.subject
    )
    assert_match(
      /Your publication proposal #{publication.full_title_and_ms} has been approved by the P&P Committee\./,
      email.encoded
    )
  end

  test 'publication approval email for P&P denied publication' do
    publication = publications(:proposed)
    secretary = users(:pp_secretary)
    publication.status = 'not approved'

    email = UserMailer.publication_approval(publication, true, secretary).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [publication.user.email], email.to
    assert_equal(
      "Publication Proposal for #{publication.abbreviated_title_and_ms} has been denied by the P&P Committee",
      email.subject
    )
    assert_match(
      /Your publication proposal #{publication.full_title_and_ms} has been denied by the P&P Committee\./,
      email.encoded
    )
  end

  test 'publication approval email for SC approved publication' do
    publication = publications(:proposed)
    secretary = users(:sc_secretary)
    publication.status = 'nominated'

    email = UserMailer.publication_approval(publication, false, secretary).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [publication.user.email], email.to
    assert_equal(
      "Publication Proposal for #{publication.abbreviated_title_and_ms} has been approved by the Steering Committee",
      email.subject
    )
    assert_match(
      /Your publication proposal #{publication.full_title_and_ms} has been approved by the Steering Committee\./,
      email.encoded
    )
  end

  test 'publication approval email for SC denied publication' do
    publication = publications(:proposed)
    secretary = users(:sc_secretary)
    publication.status = 'not approved'

    email = UserMailer.publication_approval(publication, false, secretary).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [publication.user.email], email.to
    assert_equal(
      "Publication Proposal for #{publication.abbreviated_title_and_ms} has been denied by the Steering Committee",
      email.subject
    )
    assert_match(
      /Your publication proposal #{publication.full_title_and_ms} has been denied by the Steering Committee\./,
      email.encoded
    )
  end
end
