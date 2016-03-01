## 0.14.18

### Enhancements
- **Gem Changes**
  - Updated to mysql2 0.4.3

### Refactoring
- Updated files based on RuboCop recommendations

## 0.14.17 (January 26, 2016)

### Enhancements
- **Gem Changes**
  - Updated to Ruby 2.3.0
  - Updated to rails 4.2.5.1
  - Updated to jquery-rails 4.1.0
  - Updated to mysql2 0.4.2
  - Updated to simplecov 0.11.1
  - Updated to web-console 3.0.0
  - Removed minitest-reporters

## 0.14.16 (August 25, 2015)

### Enhancements
- **General Changes**
  - Added turbolinks progress bar
  - Added a version page
- **Gem Changes**
  - Use of Ruby 2.2.3 is now recommended
  - Updated to rails 4.2.4
  - Updated to mysql2 0.3.20
  - Updated to contour 3.0.1
  - Updated to figaro 1.1.1
  - Added web-console
  - Added haml for new views

## 0.14.15 (April 24, 2015)

### Enhancements
**General Changes**
  - Streamlined login system by removing alternate logins
  - Use of Ruby 2.2.2 is now recommended
  - Updated CSS files to use SCSS
- **Gem Changes**
  - Use Figaro to centralize application configuration
  - Updated to contour 3.0.0.beta1
  - Updated to rails 4.2.1
  - Updated to kaminari 0.16.3
  - Updated to mysql2 0.3.18
  - Updated to simplecov 0.10.0

## 0.14.14 (December 12, 2014)

### Enhancements
- **Gem Changes**
  - Updated to rails 4.2.0.rc2

## 0.14.13 (November 25, 2014)

### Enhancements
- Updated Google Omniauth to no longer write to disk
- Use of Ruby 2.1.5 is now recommended
- **Gem Changes**
  - Updated to rails 4.2.0.beta4
  - Updated to contour 2.6.0.beta8
  - Updated to mysql 0.3.17

## 0.14.12 (May 29, 2014)

### Enhancements
- **General Changes**
  - Updated email styling template
- Use of Ruby 2.1.2 is now recommended
- **Gem Changes**
  - Updated to rails 4.1.1
  - Updated to mysql2 0.3.16
  - Updated to contour 2.5.0
  - Updated to carrierwave 0.10.0
  - Removed turn, and replaced with minitest and minitest-reporters
  - Removed Windows-specific gems

## 0.14.11 (February 27, 2014)

### Enhancements
- Use of Ruby 2.1.1 is now recommended
- **Gem Changes**
  - Updated to rails 4.0.3
  - Updated to contour 2.4.0.beta3
  - Updated to kaminari 0.15.1
  - Updated to mysql2 0.3.15

## 0.14.10 (January 8, 2014)

### Enhancements
- Use of Ruby 2.1.0 is now recommended
- **Gem Changes**
  - Updated to jbuilder 2.0
  - Updated to contour 2.2.1

## 0.14.9 (December 5, 2013)

### Enhancements
- Use of Ruby 2.0.0-p353 is now recommended

## 0.14.8 (December 4, 2013)

### Enhancements
- **Gem Changes**
  - Updated to rails 4.0.2
  - Updated to contour 2.2.0.rc2
  - Updated to kaminari 0.15.0
  - Updated to coffee-rails 4.0.1
  - Updated to sass-rails 4.0.1
  - Updated to simplecov 0.8.2
  - Updated to mysql 0.3.14
- Removed support for Ruby 1.9.3

## 0.14.7 (October 15, 2013)

### Enhancements
- **Gem Changes**
  - Updated to contour 2.2.0.beta2
  - Updated to carrierwave 0.9.0

### Bug Fix
- Updating a publication from the matrix view now correctly closes the popup,
  (by @susanredline)

## 0.14.6 (September 3, 2013)

### Enhancements
- **General Changes**
  - The interface now uses [Bootstrap 3](http://getbootstrap.com/)
  - Gravatars added for users
  - Reorganized Menu
- **Gem Changes**
  - Updated to contour 2.1.0.rc
  - Updated to mysql 0.3.13

## 0.14.5 (July 9, 2013)

### Enhancements
- Use of Ruby 2.0.0-p247 is now recommended
- **Gem Changes**
  - Updated to rails 4.0.0

## 0.14.4 (June 7, 2013)

### Enhancements
- Use of Ruby 2.0.0-p195 is now recommended
- **Gem Changes**
  - Updated to rails 4.0.0.rc1
  - Updated to contour 2.0.0.beta.8

## 0.14.3 (April 4, 2013)

### Enhancements
- Writing group members is no longer a required field
- Removed `None` checkbox options that added unnecessary validations
- Publication proposal file attachments are no longer required for validation

## 0.14.2 (April 1, 2013)

### Bug Fix
- Fixed a bug that prevented publications from sending reminders to committee
  members

## 0.14.1 (March 20, 2013)

### Bug Fix
- Readded missing popovers on the publication matrix

## 0.14.0 (March 20, 2013)

### Enhancements
- **Gem Changes**
  - Updated to Rails 4.0.0.beta1
  - Updated to Contour 2.0.0.beta.4

## 0.13.16 (March 20, 2013)

### Enhancements
- Use of Ruby 2.0.0-p0 is now recommended

## 0.13.15 (February 15, 2013)

### Enhancements
- ActionMailer can now also be configured to send email through NTLM
  - `ActionMailer::Base.smtp_settings` now requires an `:email` field
- Updated Contour to 1.2.0.pre8

## 0.13.14 (February 12, 2013)

### Security Fix
- Updated Rails to 3.2.12

## 0.13.13 (January 9, 2013)

### Security Fix
- Updated Rails to 3.2.11

### Enhancements
- Publications can now be archived
- Updated to Contour 1.1.2 and use Contour pagination theme
- Removing PDFKit in favor of direct LaTeX PDF generation

## 0.13.12 (January 3, 2013)

### Security Fix
- Updated Rails to 3.2.10

### Bug Fix
- User activation emails are no longer sent out when a user's status is changed
  from pending to inactive

## 0.13.11 (November 27, 2012)

### Enhancements
- Gem updates including Rails 3.2.9 and Ruby 1.9.3-p327
- File upload descriptions are no longer required when uploading a file in
  Section C and Section E

## 0.13.10 (October 16, 2012)

### Bug Fix
- Fixed a bug where a secretary could not view paper proposals that had no lead
  author (by SusanR)

## 0.13.9 (October 8, 2012)

### Enhancements
- Spreadsheets (xls, xlsx) added to valid file upload types
- Validation errors are displayed at the top of the proposal when the proposal
  fails to submit
- Full title and abbreviated title has been pulled to the top of the publication
  since these attributes are required for the quick save functionality

## 0.13.8 (October 5, 2012)

### Bug Fix
- Publication save button for secretaries now functions properly

## 0.13.7 (September 17, 2012)

### Enhancements
- Secretaries can delete publications
- Secretaries can set the lead author for new and existing publications
- Secretaries can customize publication review reminder emails for committee
  members
- Unsaved changes while editing publications now asks the user if they want
  leave the page
- Updated to Contour 1.1.0

## 0.13.6 (September 5, 2012)

### Bug Fix
- Sorting publications on Publication Matrix now correctly sorts by the selected
  column (by SusanR)

## 0.13.5 (August 13, 2012)

### Enhancements
- Updated to Rails 3.2.8
  - Removed deprecated use of update_attribute for Rails 4.0 compatibility
- **Email Changes**
  - Default application name is now added to the from: field for emails
  - Email subjects no longer include the application name
- About page reformatted to include links to github and contact information

### Refactoring
- Mass-assignment attr_accessible and params slicing implemented to leverage
  Rails 3.2.x configuration defaults
- Consistent sorting and display of model counts used across all objects,
  (publications, users)

### Testing
- Use ActionDispatch for Integration tests instead of ActionController

## 0.13.4 (June 22, 2012)

### Enhancements
- Update to Rails 3.2.6 and Contour 1.0.2
- Links with confirm: now use data: { confirm: } to account for deprecations in
  Rails 4.0

## 0.13.3 (June 7, 2012)

### Enhancements
- Update to Rails 3.2.5 and Contour 1.0.1
- Updated Devise configuration files for devise 2.1.0
- Inline editing of publication matrix now uses a popup box

## 0.13.2 (May 9, 2012)

### Enhancements
- Use Contour for User account Confirmations and Unlocks

## 0.13.1 (May 4, 2012)

### Bug Fix
- Fix Registration page to use new Contour login attributes

## 0.13.0 (May 2, 2012)

### Enhancements
- Reviewers can now log in directly to the publication they should review
- Update to Contour 1.0.0 with Twitter Bootstrap
- Updated to Rails 3.2.8
  - Removed deprecated use of update_attribute for Rails 4.0 compatibility

## 0.12.2 (March 22, 2012)

### Enhancements
- Update to Rails 3.2.2 and Contour 0.10.2 with Contour-Minimalist theme

## 0.12.1 (January 23, 2012)

### Refactoring
- **Gem Changes**
  - Rails 3.2.0
  - Contour ~> 0.9.3
- Devise migration and configuration file updated
- Environment files updated to be in sync with Rails 3.2.0

## 0.12.0 (January 16, 2012)

### Enhancements
- The Publication Matrix can now be downloaded as a PDF
- Updated to Contour 0.9.0 and Rails 3.2.0.rc2

### Testing
- TravisCI is now setup for continuous integration testing,
  [http://travis-ci.org/remomueller/review/builds](http://travis-ci.org/remomueller/review/builds)

## 0.11.2 (November 30, 2011)

### Testing
- Updated a test description to accurately reflect what it was actually testing

## 0.11.1 (November 30, 2011)

### Bug Fix
- Fixed user name autocomplete not working for non-system admins

## 0.11.0 (November 23, 2011)

### Enhancements
- Users can now see all publications on the publications matrix as long as they
  are not listed as 'draft' or 'not approved'
- Secretaries can now directly modify existing publications
- The Publication Timeline can now be viewed on the Publication Matrix by
  hovering over the additional information icon
- Writing group proposed nominations and finalized nominations are now both
  displayed on the Publication Matrix
- Secretaries can remove malformed nominations when editing a publication on the
  publication matrix

### Bug Fix
- Backspace no longer goes back in browser history when trying to remove a
  selected Writing Group Committee nomination

### Testing
- Test coverage at 100%

## 0.10.3 (November 7, 2011)

### Bug Fix
- Sending Email Reminders now correctly updates when the selected reviewer is on
  both the P&P committee and the Steering committee

## 0.10.2 (November 7, 2011)

### Bug Fix
- User Publication Reviews 'review updates' are no longer sent when the
  secretary hits "Send Reminder"

## 0.10.1 (October 18, 2011)

### Refactoring
- Static Assets should be served by Apache not Rails

## 0.10.0 (October 18, 2011)

### Enhancements
- Update to Rails 3.1.1
- Login instructions on the downloadable PDF have been updated
- Quick save icon added to allow users to quick save a draft of a publication
  they are editing
- Users can now add additional comments in Section E

## 0.9.2 (September 9, 2011)

### Refactoring
- Updating to Contour version 0.5.0

## 0.9.1 (September 7, 2011)

### Enhancements
- Update to Rails 3.1.0
- Now uses Contour for application layout, registration, and authentication

## 0.9.0 (September 2, 2011)

### Enhancements
- Update to Rails 3.1.0.rc6
- **Writing Group Nomination Changes**
  - Tokenized when separated using commas
  - Parsed to show corresponding emails of users who are already in the system
  - Users writing 'Me' will now get a drop down item that gives their full
    username
- Steering committee secretaries are now notified if a review is created for a
  publication that has already been SC Approved

## 0.8.1 (August 18, 2011)

### Enhancements
- Menu bar now sticks to the top of the window when the user scrolls down the
  page

## 0.8.0 (August 17, 2011)

### Enhancements
- Remove the need for reviewers to click "Create Review" before being able to
  fill out a new review
- The secretary can now email reminders and see when email reminders were sent
  to reviewers
- Reviewers can now create and update reviews for a publication at any point
  after it has been proposed

### Testing
- Integration tests added to check that
  - Valid users are forwarded to the correct url after login
  - Pending users aren't allowed to login
  - Deleted users aren't allowed to login
- Functional tests now check that publication matrix is initially sorted based
  on the responsibility of the user

### Bug Fix
- Don't allow inactive or deleted users to login, caused by Devise updating
  active? to active_for_authentication?

## 0.7.1 (August 15, 2011)

### Enhancements
- Modified the authentication system so that it can authenticate correctly when
  behind a reverse proxy and within a firewall

## 0.7.0 (August 5, 2011)

### Enhancements
- Reviewers on the P&P committee and in the Steering committee are now presented
  a simpler interface for creating a review
- A link to the manual is now provided to document the login process
- Update Rails to 3.1
- Update Devise to 1.3.4 and Omniauth 0.2.6

### Refactoring
- JavaScript rewritten using CoffeeScript

## 0.6.0 (July 22, 2011)

### Enhancements
- Manuscript Number is now included in Publication Approval emails and
  Publication Approval Reminder emails
- Publications Index is now easier to sort by Marked for SC review and Marked
  for P&P review
  - P&P committee members and secretaries will have Marked for P&P review
    filtered to top when they first load the page
  - SC committee members and secretaries will have Marked for SC review filtered
    to top when they first load the page
  - Members of both will have Marked for P&P at top followed by Marked for SC at
    top of page

### Test Coverage
- Created initial test coverage for all unit and functional tests

## 0.5.0 (May 2, 2011)

## 0.4.0 (April 22, 2011)

## 0.3.0 (April 8, 2011)

## 0.2.0 (March 16, 2011)

## 0.1.0 (March 3, 2011)
