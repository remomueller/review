# Use to configure basic appearance of template
Contour.setup do |config|
  
  # Enter your application name here. The name will be displayed in the title of all pages, ex: AppName - PageTitle
  config.application_name = DEFAULT_APP_NAME
  
  # Enter your application version here. Do not include a trailing backslash. Recommend using a predefined constant
  config.application_version = Review::VERSION::STRING
  
  # Enter your application header background image here.
  config.header_background_image = 'brigham.png'

  # Enter your application header title image here.
  config.header_title_image = 'chatpublications.png'
  
  # Enter the items you wish to see in the menu
  config.menu_items = [{
    :name => 'Login', :id => 'auth', :display => 'not_signed_in', :position => 'right', :position_class => 'right', :condition => 'true',
    :links => [{:name => 'Login', :path => 'new_user_session_path'}, {:html => "<hr>"}, {:name => 'Sign Up', :path => 'new_user_registration_path'}]
  },
  {
    :name => 'current_user.name', :eval => true, :id => 'auth', :display => 'signed_in', :position => 'right', :position_class => 'right', :condition => 'true',
    :links => [{:html => '"<div style=\"white-space:nowrap\">"+current_user.name+"</div>"', :eval => true}, {:html => '"<div class=\"small quiet\">"+current_user.email+"</div>"', :eval => true}, {:name => 'Authentications', :path => 'authentications_path'}, {:html => "<hr>"}, {:name => 'Logout', :path => 'destroy_user_session_path'}]
  },
  {
    :name => 'Publications', :id => 'publications', :display => 'always', :position => 'left', :position_class => 'left', :condition => 'true',
    :links => [{:name => 'Publications', :path => 'publications_path'},
               {:name => '&raquo;New', :path => 'new_publication_path'},
               {:html => "<hr>"},
               {:name => 'About', :path => 'about_path'}]
  },
  {
    :name => 'Manual', :id => 'manual', :display => 'not_signed_in', :position => 'left', :position_class => 'left_center',
    :links => [{:name => 'Manual', :path => 'SITE_URL + \'/documents/CHAT Publications Manual.pdf\'', :target => '_blank', :image => "image_tag('contour/pdf.png', :style => 'vertical-align:middle')"}]
  },
  {
    :name => 'Users', :id => 'users', :display => 'signed_in', :position => 'left', :position_class => 'left_center',
    :links => [{:name => 'Users', :path => 'users_path'}]
  }]
  
end