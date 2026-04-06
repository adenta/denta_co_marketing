Rails.application.routes.draw do
  post "csp-violation-reports" => "csp_violation_reports#create", as: :csp_violation_reports
  get "robots.txt" => "seo#robots", as: :robots
  get "feed.xml" => "seo#feed", as: :feed, defaults: { format: :xml }
  get "sitemap.xml" => "seo#sitemap", as: :sitemap, defaults: { format: :xml }
  resource :blog_subscription, only: [] do
    get :confirm
  end
  resource :developer_session, only: [ :create ]
  resource :session, only: [ :new, :destroy ]
  resources :passwords, only: [ :new, :edit ], param: :token
  get "writing" => "writings#index", as: :writing
  get "projects" => redirect("/writing"), as: :projects
  get "p/:slug" => "posts#show", as: :content_post
  resources :chats, only: [ :index, :show ]
  mount Blazer::Engine, at: "blazer"

  namespace :api do
    namespace :v1 do
      resources :blog_subscriptions, only: [ :create ]
      resource :developer_session, only: [ :create ]
      resource :session, only: [ :create, :destroy ]
      resources :passwords, only: [ :create, :update ], param: :token
      resources :chats, only: [ :create ]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
