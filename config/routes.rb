# frozen_string_literal: true

Rails.application.routes.draw do
  # Pages not affiliated with any collection
  root 'pages#home'
  get 'about' => 'pages#about'
  get 'help' => 'pages#help'
  get 'welcome' => 'pages#home'
  get 'news' => 'pages#news'

  # Collections

  resources :challenges do
    get 'participations' => 'participations#index', as: :participations
    get 'participations/:user_id' => 'participations#show', as: :participation
    post 'participations' => 'participations#create'
    delete 'participations/:user_id' => 'participations#destroy'
  end
  get 'challenges/:id/entries' => 'challenges#entries', as: :challenge_entries

  resources :comments, only: %i[show destroy]

  resources :moderator_applications

  resources :submissions do
    resources :comments
  end

  resources :users do
    get 'awards' => 'awards#index', as: :awards
    get 'awards/:badge_id' => 'awards#show', as: :award
  end
  get 'users/:id/submissions' => 'users#submissions', as: :user_submissions
  get 'find' => 'users#index'

  # Sessions
  get 'signup' => 'users#new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  # Notifications
  resources :notifications, only: %i[index] do
    collection do
      post :mark_as_read
    end
  end

  # Password resets
  resources :password_resets, only: %i[new create edit update]

  # Email verification
  get 'users/:user_id/email_verification' => 'email_verifications#new',
      as: :new_email_verification
  post 'users/:user_id/email_verification' => 'email_verifications#create',
       as: :email_verifications
  get 'users/:user_id/email_verification/:token' => 'email_verifications#edit',
      as: :edit_email_verification
  post 'users/:user_id/email_verification/:token' => 'email_verifications#update',
       as: :email_verification

  # Cross-site authentication
  if ENV['X_AUTH_HOST'].present?
    get 'x_site_auth/auto_login_available' => 'x_site_auth#auto_login_available'
    get 'x_site_auth/login' => 'x_site_auth#login'
    post 'x_site_auth/sign' => 'x_site_auth#sign'
  end
end
