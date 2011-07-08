Review::Application.routes.draw do

  resources :user_publication_reviews

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

  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failure'

  devise_for :users, :controllers => {:registrations => 'registrations'}, :path_names => { :sign_up => 'register', :sign_in => 'login' }
  
  resources :users do
    collection do
      post :filtered
    end
  end
  
  resources :authentications
  
  match "/about" => "sites#about", :as => :about

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "publications#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
