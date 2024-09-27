Rails.application.routes.draw do
  resources :documents, only: [:new, :create, :index, :show]
end
