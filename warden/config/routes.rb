Rails.application.routes.draw do
  get '/login', to: 'login#new'
  post '/login', to: 'login#login'

  get '/logged_in', to: 'login#logged_in'
end
