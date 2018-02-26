Rails.application.routes.draw do
  namespace :api do
    post :actions, controller: 'slack'
    get :invalid_token, controller: 'slack'
    post :events, controller: 'slack'
    
    resources :people, only: [] do
      collection do
        post :status
        post :register
        post :away
        post :here
      end
    end
  end

  resources :people
  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'welcome#index'
end
