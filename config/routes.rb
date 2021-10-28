Rails.application.routes.draw do
  resources :workouts
  resources :sessions
  resources :workout_routes
  resources :routes
  resources :users
  resources :workout_types
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
