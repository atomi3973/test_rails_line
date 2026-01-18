Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  
  root 'home#index' # ここを追加
  post '/callback', to: 'line_bot#callback'
end