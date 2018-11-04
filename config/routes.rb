Rails.application.routes.draw do
  devise_for :users
  root "pages#home"
  get 'pages/home', to: 'pages#home'

  resources :recipes do
    resources :comments, only: [:create]
    member do
      post 'like'
    end
  end

  resources :chefs, except: [:new]

  resources :ingredients, except: [:destroy]

  mount ActionCable.server => '/cable'
  get '/chat', to: 'chatrooms#show'

  resources :messages, only: [:create]

end
