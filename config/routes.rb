Review::Application.routes.draw do
  
  resources :publications do
    collection do
      get :search
    end
    member do
       post :pp_approval
       post :sc_approval
       post :show_subcommittee_decision
       post :edit_subcommittee_decision
       post :show_steering_committee_decision
       post :edit_steering_committee_decision
       post :upload_manuscript
       post :edit_manuscript
       post :show_manuscript
       post :destroy_manuscript
       post :send_reminder
       post :inline_edit
       post :inline_update
       post :inline_show
       post :tag_for_review
       post :remove_nomination
    end
  end

  devise_for :users, :controllers => {:registrations => 'contour/registrations', :sessions => 'contour/sessions', :passwords => 'contour/passwords'}, :path_names => { :sign_up => 'register', :sign_in => 'login' }
  resources :users
  
  resources :user_publication_reviews
  
  match "/about" => "sites#about", :as => :about

  root :to => "publications#index"
end
