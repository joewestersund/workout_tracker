# == Route Map
#

Rails.application.routes.draw do

  resources :default_data_points
  resources :workouts

  resources :workout_types, shallow: true do
    resources :routes, shallow: true do
      resources :default_data_points
    end
    resources :data_types, shallow: true do
      resources :dropdown_options
      resources :data_points
    end
  end

  post '/workout_types/:id/move_up', to: 'workout_types#move_up'
  post '/workout_types/:id/move_down', to: 'workout_types#move_down'

  #get '/workout_types/:id/default_workout_routes', to: 'workout_types#default_workout_routes'

  get '/routes', to: 'routes#default_index', as: :routes_default  # show routes for the first workout type
  get '/data_types', to: 'data_types#default_index', as: :data_types_default  # show dts for the first workout type
  #get '/dropdown_options', to: 'dropdown_options#default_index', as: :dropdown_options_default # show adts options for the first adt for the first workout type

  #get '/routes/:workout_type_id', to: 'routes#index', as: :routes
  #get '/routes/:workout_type_id/new', to: 'routes#new', as: :new_route
  #post '/routes/:workout_type_id/', to: 'routes#create', as: :create_route
  #post '/routes/:workout_type_id/:id/edit', to: 'routes#edit', as: :edit_route
  #post '/routes/:workout_type_id/:id', to: 'routes#update', as: :update_route
  #delete '/routes/:workout_type_id/:id', to: 'routes#destroy', as: :destroy_route
  post '/routes/:id/move_up', to: 'routes#move_up', as: :move_route_up
  post '/routes/:id/move_down', to: 'routes#move_down', as: :move_route_down

  #resources :workout_routes

  resources :data_points
  resources :dropdown_options
  post '/dropdown_options/:id/move_up', to: 'dropdown_options#move_up'
  post '/dropdown_options/:id/move_down', to: 'dropdown_options#move_down'

  post '/data_types/:id/move_up', to: 'data_types#move_up'
  post '/data_types/:id/move_down', to: 'data_types#move_down'

  resources :sessions, only: [:new, :create, :destroy]
  get '/signin', to: "sessions#new"
  delete '/signout', to: "sessions#destroy"

  resources :users, except: [:show, :destroy]
  get '/signup', to: 'users#new' # creates named path 'signup'
  get 'password/forgot', to: 'users#forgot_password'
  post 'password/send_reset_email', to: 'users#send_password_reset_email'
  get 'password/reset/:token', to: 'users#reset_password'
  get 'activate_account/:token', to: 'users#reset_password'

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
