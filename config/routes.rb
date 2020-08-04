Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
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

  get        'seat'               => 'hosts#index'#'users#seat'
  get        'lookup'             => 'seats#lookup'
  get        'link'               => 'identities#link'
  get        'qconbyoc'           => 'identities#qconbyoc'
  match      'identities/:id/unlink', to: 'identities#unlink', as: 'unlink_identity', via: :post
  match      'messages/:id/clear', to: 'messages#clear', as: 'clear_message', via: [:get, :post]

  match      'users/:id/ban', to: 'users#ban', as: 'ban_user', via: :post
  match      'users/:id/unban', to: 'users#unban', as: 'unban_user', via: :post
  match      'hosts/:id/ban', to: 'hosts#ban', as: 'ban_host', via: :post
  match      'hosts/:id/unban', to: 'hosts#unban', as: 'unban_host', via: :post
  match      'identities/:id/ban', to: 'identities#ban', as: 'ban_identity', via: :post
  match      'identities/:id/unban', to: 'identities#unban', as: 'unban_identity', via: :post

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
end
