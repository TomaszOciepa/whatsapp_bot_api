Rails.application.routes.draw do
 
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  namespace :api do
    post "/messages", to: "messages#create"
  end

  namespace :admin do
    root to: "dashboard#index"
  end
  
end
