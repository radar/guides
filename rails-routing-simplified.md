# Rails Routing Simplified

This guide gives an extremely simplified overview of how Rails requests are handled in a typical Rails request. For a more thorough overview, I would recommend reading [The Official Rails Routing Guide](http://guides.rubyonrails.org/routing.html).

## A simple request

Rails operates on top of another gem called Rack. Rack provides a common API for Ruby web applications that use frameworks such as Rails. When a request comes into your server, Rack is the first piece of Ruby code that the request goes to. This request is then handled by rack by passing it through a set of items known as "middleware".

Each piece of middleware can modify the request in different ways, adding headers to the response or even returning their own custom responses based on certain conditions. Once a request has passed through the stack of middleware, it then goes to your Rails application.

Once it's inside your Rails application, it will be dealt with by your application's router, which is configured inside `config/routes.rb`. A route can be defined as simply as this:

```ruby
Your::Application.routes.draw do
  get '/home' => "home#index"
end
```

This routing code defines a route that responds only to HTTP `GET` requests to `/home`, and gets `HomeController` to serve the request with its `index` action. When you make a request to this action, a new instance of the `HomeController` class is initialized and the `index` method is called. This method should make calls to models (or other data sources), collecting information for your views. Once this method has finished running, then an implicit render takes place, rendering the view template with the same name as the action: `app/views/home/index.html.erb`.
