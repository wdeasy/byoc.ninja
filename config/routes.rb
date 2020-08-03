Rails.application.routes.draw do
  root      'hosts#index'
  get       'login'               => 'sessions#login'
  match     'auth/:provider/callback' => 'sessions#create', via: [:get, :post]
  match     'auth/failure', :to   => 'sessions#failure', via: [:get, :post]
  delete    'logout'              => 'sessions#destroy'
  get       'privacy_policy'      => 'static_pages#privacy_policy'

  get       'admin/hosts'         => 'admin#hosts'
  get       'groups/auto'         => 'groups#auto'
  get       'messages/clear_all'  => 'messages#clear_all'
  get       'settings'            => 'users#edit'
  get       'seats'               => 'seats#index'
  get       'seats/update'        => 'seats#update'

  get       'logs/update_hosts'   => 'logs#update_hosts'
  get       'logs/update_seats'   => 'logs#update_seats'

  get        'seat'               => 'users#seat'
  get        'lookup'             => 'seats#lookup'
  get        'link'               => 'identities#link'
  get        'qconbyoc'           => 'identities#qconbyoc'
  match      'identities/:id/unlink', to: 'identities#unlink', as: 'unlink_identity', via: :post
  match      'messages/:id/clear', to: 'messages#clear', as: 'clear_message', via: [:get, :post]

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :hosts, :only => [:index, :update]
      resources :games, :only => [:index, :update]
      resources :seats, :only => [:index]
    end
  end

  resources :identities, :except => [:new, :create, :show]
  resources :contacts, :only => [:new, :create]
  resources :games, :except => [:show]
  resources :hosts, :except => [:show]
  resources :users, :except => [:show]
  resources :groups, :except => [:show]
  resources :networks, :except => [:show]
  resources :messages, :except => [:show]
  resources :mods, :except => [:show]
  resources :filters, :except => [:show]

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
