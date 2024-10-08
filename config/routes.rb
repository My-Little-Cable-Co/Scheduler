Rails.application.routes.draw do
  resources :commercials do
    post 'rescan', on: :collection
  end
  resources :shows do
    post 'rescan', on: :collection
    resources :seasons do
      resources :episodes
    end
  end
  resources :channels do
    resources :airings, except: [:update, :edit, :index]
    get 'schedule', on: :member
  end
  get 'schedule', to: 'schedule#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  mount GoodJob::Engine => 'good_job'
end
