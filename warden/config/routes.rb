Banana::Application.routes.draw do
  get '/login', :to => "login#new"
  post '/login', :to => "login#login"
end
