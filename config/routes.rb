Rails.application.routes.draw do
  namespace :observability do
    resources :errors, only: :index
  end

  namespace :api do
    namespace :v1 do
      resources :organizations, only: [] do
        resources :projects, only: [ :index, :show, :create, :update ] do
          resources :tasks, only: [ :index, :show, :create, :update ]
        end
      end
    end
  end
  resource :notification_preference, only: [ :edit, :update ]
  resources :invitation_acceptances, only: [ :edit, :update ], param: :token, path: "invitations/accept"
  resources :password_resets, only: [ :new, :create, :edit, :update ], param: :token
  resource :session, only: [ :new, :create, :destroy ]
  resources :users, only: [ :new, :create ]

  resources :organizations, only: [ :index, :show, :new, :create ] do
    resource :search, only: :show, controller: "organization_searches"
    resources :organization_invitations, only: [ :new, :create ], path: "invitations"
    resources :projects, only: [ :show, :new, :create, :edit, :update ] do
      resources :tasks, only: [ :show, :new, :create, :edit, :update ] do
        resources :task_comments, only: [ :create ]
      end
    end
  end

  root "dashboard#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
