# Use to configure basic appearance of template
Contour.setup do |config|

  # Enter your application name here. The name will be displayed in the title of all pages, ex: AppName - PageTitle
  config.application_name = DEFAULT_APP_NAME

  # If you want to style your name using html you can do so here, ex: <b>App</b>Name
  config.application_name_html = '<span style="color:#D4002F">C</span><span style="color:#56DF00">H</span><span style="color:#D9DE00">A</span><span style="color:#23FFFF">T</span> <span style="color:#2F0C72">Publications</span>'

  # Enter your application version here. Do not include a trailing backslash. Recommend using a predefined constant
  config.application_version = Review::VERSION::STRING

  # Enter your application header background image here.
  config.header_background_image = ''

  # Enter your application header title image here.
  config.header_title_image = 'chatpublications.png'

  # Enter the items you wish to see in the menu
  config.menu_items = [
    {
      name: 'Login', display: 'not_signed_in', path: 'new_user_session_path', position: 'right',
      links: [{ name: 'Sign Up', path: 'new_user_registration_path' }]
    },
    {
      name: 'current_user.name', eval: true, display: 'signed_in', path: 'user_path(current_user)', position: 'right',
      links: [{ html: '"<div class=\"small\" style=\"color:#bbb\">"+current_user.email+"</div>"', eval: true },
              { name: 'Authentications', path: 'authentications_path', condition: 'not PROVIDERS.blank?' },
              { html: "<br />" },
              { name: 'Logout', path: 'destroy_user_session_path' }]
    },
    {
      name: 'About', display: 'not_signed_in', path: 'about_path', position: 'left',
      links: []
    },
    {
      name: 'Manual ', display: 'not_signed_in', path: 'SITE_URL + \'/documents/CHAT Publications Manual.pdf\'', target: '_blank', position: 'left', image: 'contour/pdf.png', image_options: { style: 'vertical-align:middle' },
      links: []
    },
    {
      name: 'Publications', display: 'signed_in', path: 'publications_path', position: 'left',
      links: [{ name: '&raquo;New', path: 'new_publication_path' },
              { html: "<br />" },
              { name: 'About', path: 'about_path' }]
    },
    {
      name: 'Users', display: 'signed_in', path: 'users_path', position: 'left', condition: 'current_user.system_admin?',
      links: []
    }
  ]

  # Enter an address of a valid RSS Feed if you would like to see news on the sign in page.
  config.news_feed = 'https://sleepepi.partners.org/category/informatics/chat-publications/feed/rss'

  # Enter the max number of items you want to see in the news feed.
  config.news_feed_items = 3

end
