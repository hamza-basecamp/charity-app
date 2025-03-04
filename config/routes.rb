Rails.application.routes.draw do
  require 'sidekiq/web'
  devise_for :users
  mount Sidekiq::Web => '/sidekiq'

  root to: "home#index"

  get 'charity_dashboard', to: 'home#charity', as: 'charity_dashboard'
  get 'charity_profile', to: 'home#profile', as: 'charity_profile'  
  patch 'charity_profile_update', to: 'home#update', as: 'charity_profile_update'  # Define update route


  get 'admin_dashboard', to: 'admin#index', as: :admin_dashboard
  get 'admin_charities', to: 'admin#charities', as: :admin_charities
  get 'admin_campaign', to: 'admin#campaign', as: :admin_campaign
  patch 'admin_create_campaign', to: 'admin#create_campaign', as: 'admin_create_campaign' 
  get 'admin_orders', to: 'admin#orders', as: :admin_orders
  patch 'admin_update_charity/:charity_id', to: 'admin#update_charity', as: :admin_update_charity
  patch 'admin_update_campaign/:campaign_id', to: 'admin#update_campaign', as: :admin_update_campaign
  

  
  resources :admin, only: [] do
    member do
      patch :approve
      patch :disapprove
      patch :campaign_active
      patch :campign_deactive
      delete :delete_campaign
    end
  end
  

  scope :auth do
    scope :shopify do
      get '/login',                 to: 'shopify#authenticate'
      get '/callback',              to: 'shopify#auth_callback'
    end
  end

  scope :gdpr do
    post '/customer_redact'             =>  'webhook#customer_redact'
    post '/shop_redact'                 =>  'webhook#shop_redact'
    post '/customer_data_request'       =>  'webhook#customer_data_request'
  end

  scope :webhook do
    post '/orders_create'             =>  'webhook#orders_create'
    post '/orders_paid'               =>  'webhook#orders_paid'
    get  '/charities'                 => 'webhook#charities'
    get  '/featured_charities'        => 'webhook#featured_charities'
    get  '/accept_widget'             => 'webhook#accept_widget'
  end

end
