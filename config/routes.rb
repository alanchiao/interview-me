Kongming92Tokutei12RlaceyAchiao68Final::Application.routes.draw do

  root  'static_pages#home'

  resources :categories, only: [:show]

  post 'attempts/autosave', to: 'attempts#autosave', as: :autosave_attempts
  post 'comments/:id/vote', to: 'comments#vote', as: :vote_comment

  resources :problems, except: [:edit, :update, :destroy] do
    member do
      get 'tests'
      get 'comments'
      post 'comments', to: 'problems#add_comment', as: :add_comment
      post 'hints', to: 'problems#add_hints', as: :add_hints
      post 'tests', to: 'problems#add_tests', as: :add_tests
    end
  end

  resources :users, only: [:new, :create, :show]
  match '/signup', to: 'users#new', via: 'get'

  resources :sessions, only: [:new, :create, :destroy]
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  match '/permissions', to: 'static_pages#permissions', via: 'get'
  match '/manage_admins', to: 'static_pages#manage_admins', :as =>'manage_admins', via: 'post'
  match '/manage_content_creators', to: 'static_pages#manage_content_creators', :as =>'manage_content_creators', via: 'post'
  match '/analytics/:id', to: 'users#analytics', via: 'get'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
