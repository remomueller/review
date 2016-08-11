# frozen_string_literal: true

Rails.application.routes.draw do
  root 'publications#index'

  resources :publications do
    collection do
      get :search
      get :print
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

  devise_for :users, path_names: { sign_up: 'join', sign_in: 'login' }, path: ''

  resources :users do
    collection do
      post :activate
    end
  end

  resources :user_publication_reviews

  scope module: 'application' do
    get :about
    get :version
  end
end
