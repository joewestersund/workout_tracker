# == Route Map
#

Rails.application.routes.draw do
  resources :workout_type_additional_data_type_values
  resources :workout_type_additional_data_type_options
  resources :workout_type_additional_data_types
  resources :workouts
  resources :workout_routes
  resources :routes
  resources :workout_types
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :sessions, only: [:new, :create, :destroy]
  get '/signin', to: "sessions#new"
  delete '/signout', to: "sessions#destroy"

  resources :users, except: [:show, :destroy]
  get '/signup', to: 'users#new' # creates named path 'signup'
  get 'password/forgot', to: 'users#forgot_password'
  post 'password/send_reset_email', to: 'users#send_password_reset_email'
  get 'password/reset/:token', to: 'users#reset_password'

  get '/profile/edit_password', to: 'users#edit_password'
  get '/profile/edit', to: 'users#edit_profile'
  patch '/profile/update_password', to: 'users#update_password'
  patch '/profile/update', to: 'users#update_profile'

  get "/summaries/by_account"
  get "/summaries/by_category"
  get "/summaries/by_transaction_direction"

  get '/about', to: 'static_pages#about' # creates named path 'about'
  get '/welcome', to: 'static_pages#welcome' # creates named path 'welcome'

  root 'static_pages#about'

end
