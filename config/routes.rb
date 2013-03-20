Review::Application.routes.draw do

  resources :publications do
    collection do
      get :search
      get :print
      get :print_latex
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
       post :inline_update
       post :tag_for_review
       post :remove_nomination
       post :archive
    end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users do
    collection do
      post :activate
    end
  end

  resources :user_publication_reviews

  get "/about" => "sites#about", as: :about

  root to: "publications#index"

  # See how all your routes lay out with "rake routes"

end
