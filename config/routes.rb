Rails.application.routes.draw do
  root      'servers#index'
  get       'login'               => 'sessions#login'
  post      'auth/steam/callback' => 'sessions#create'
  match     'auth/failure', :to   => 'sessions#failure', via: [:get, :post]
  delete    'logout'              => 'sessions#destroy'
  get       'privacy_policy'      => 'static_pages#privacy_policy'

  get       'admin/servers'       => 'admin#servers'
  get       'groups/auto'         => 'groups#auto'
  get       'protocols/query'     => 'protocols#query'
  get       'networks/update_all' => 'networks#update_all'
  get       'messages/clear'      => 'messages#clear'
  get       'settings'            => 'users#edit'
  get       'seats'               => 'seats#index'
  get       'seats/update'        => 'seats#update'

  resources :contacts, :only      => [:new, :create]
  resources :games, :param        => :gameid
  resources :servers, :param      => :gameserverip
  resources :users, :param        => :steamid
  resources :groups, :param       => :groupid64
  resources :networks
  resources :messages
  resources :protocols

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
