Rails.application.routes.draw do
  resources :commercials
  resources :shows
  resources :channels do
    resources :airings, except: [:update, :edit, :index]
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'
end
