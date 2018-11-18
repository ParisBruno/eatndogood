Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users
  root "pages#home"
  get 'pages/home', to: 'pages#home'

  resources :recipes do
    resources :comments, only: [:create]
    member do
      post 'like'
    end
  end

  get 'guests', to: 'guests#index'

  resources :chefs, except: [:new]
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
