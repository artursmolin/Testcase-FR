Rails.application.routes.draw do
  get '/', to: 'application#index', as: :search
  get '/forecast', to: 'application#forecast', as: :forecast
  post '/search', to: 'application#search', as: :set_search
end
