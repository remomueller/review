Review::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  match '/auth/failure' => 'authentications#failure'
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/:provider' => 'authentications#passthru'

  resources :authentications

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
    end
  end

  devise_for :users, :controllers => {:registrations => 'registrations'}, :path_names => { :sign_up => 'register', :sign_in => 'login' }
  resources :users do
    collection do
      post :filtered
    end
  end
  
  resources :user_publication_reviews
  
  match "/about" => "sites#about", :as => :about

  root :to => "publications#index"
  
  # See how all your routes lay out with "rake routes"
end
