Rails.application.routes.draw do
  root      'hosts#index'
  get       'login'               => 'sessions#login'
  post      'auth/steam/callback' => 'sessions#create'
  match     'auth/failure', :to   => 'sessions#failure', via: [:get, :post]
  delete    'logout'              => 'sessions#destroy'
  get       'privacy_policy'      => 'static_pages#privacy_policy'

  get       'admin/hosts'         => 'admin#hosts'
  get       'groups/auto'         => 'groups#auto'
  get       'messages/clear'      => 'messages#clear'
  get       'settings'            => 'users#edit'
  get       'seats'               => 'seats#index'
  get       'seats/update'        => 'seats#update'

  get       'api/hosts'           => 'hosts#json'
  get       'api/seats'           => 'seats#json'

  get       'logs/update_hosts'   => 'logs#update_hosts'
  get       'logs/update_seats'   => 'logs#update_seats'

  get        'seat'               => 'users#seat'
  get        'lookup'             => 'seats#lookup'
  match      'messages/:id/hide', to: 'messages#hide', as: 'hide_message', via: [:get, :post]

  resources :contacts, :only      => [:new, :create]
  resources :games
  resources :hosts
  resources :users
  resources :groups
  resources :networks
  resources :messages
  resources :mods

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
