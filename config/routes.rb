# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  resources :allergens
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount Ckeditor::Engine => '/ckeditor'

  devise_for :users
  root "pages#welcome"
  get 'pages/welcome', to: 'pages#welcome'

  resources :recipes do
    resources :comments, only: [:create]
    member do
      post 'like'
    end
  end

  get 'guests', to: 'guests#index'
  post 'guests', to: 'guests#send_emails'
  get "signupguest" => "guests#new", :as=>"newguestwithoutid"

  scope ':user' do
    resources :guests, only: %i[index send_emails]
  end

  resources :chefs #, except: [:new]
  resources :ingredients, except: [:destroy]
  resources :messages, only: [:create]
  resources :pages do
    collection do
      post 'welcome/edit'
      post 'about/edit'
      get 'welcome', to: 'welcome'
      get 'about',   to: 'about'
    end
  end
  mount ActionCable.server => '/cable'

  get '/chat', to: 'chatrooms#show'
end
