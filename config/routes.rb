Rails.application.routes.draw do
  # Authentication
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  get "signup", to: "users#new"
  post "signup", to: "users#create"
  resources :users, only: [:show], param: :username

  # Activities feed
  resources :activities, only: [:index]

  # Search
  get "search", to: "search#index", as: :search

  # Invite links
  get "join/:token", to: "invites#show", as: :join

  # Blockchain explorer
  resources :blocks, only: [:index, :show]

  # Communities and nested resources
  resources :communities, param: :slug do
    resource :membership, only: [:create, :destroy]
    resources :proposals do
      resources :votes, only: [:create]
    end
    resources :laws, only: [:index, :show] do
      resources :law_votes, only: [:create], path: "vote"
    end
    resources :memes, only: [:index, :show, :new, :create, :destroy] do
      resources :meme_votes, only: [:create], path: "vote"
      resources :comments, only: [:create, :destroy] do
        resource :comment_vote, only: [:create], path: "vote"
      end
    end
    resources :posts, only: [:index, :show, :new, :create, :destroy] do
      resources :post_votes, only: [:create], path: "vote"
      resources :comments, only: [:create, :destroy] do
        resource :comment_vote, only: [:create], path: "vote"
      end
    end
  end

  # Global pages (aggregate across all communities)
  get 'posts', to: 'global_posts#index', as: :global_posts
  get 'memes', to: 'global_memes#index', as: :global_memes
  get 'proposals', to: 'global_proposals#index', as: :global_proposals

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "global_proposals#index"
end
