# Banana, A Warden Example Application

Warden is a lightweight authentication library for Ruby applications. It's most
commonly used in conjunction with the Devise gem.

This is a short guide on how Warden authenticates users in your applications.

You can follow along with the example app inside this directory.

## Configuring Warden

Warden works by placing a thing called "middleware" in the "rack stack" for
your application. There's a whole bunch of middleware that make up a Rails
application, and you can view these by running the `rake middleware` command.
A little known fact.

A request headed for your application goes through this middleware stack piece
by piece and those pieces of middleware can modify the request (or in Rack
parlance, it's called an "environment") in certain ways by adding headers,
modifying content and other fun things. They can even stop the request in its
tracks and return a response immediately.

There's a particular piece of middleware that the Warden gem provides called,
`Warden::Manager`. Inside this guide's example application, you can see this
middleware. This middleware is configured like this inside
`config/application.rb`:

```ruby
config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :password

  manager.serialize_into_session do |user|
    user.id
  end

  manager.serialize_from_session do |id|
    User.find(id)
  end
end
```

This tells the Rails application to use the `Warden::Manager` middleware piece,
and to use the "password" _strategy_. We'll cover the `serialize` method calls a
little later on.

Strategies are potential ways that Warden can authenticate users. We could set up more than just the "password" strategy with the intention of allowing users to authenticate in more than one way, but we're not going to do that here. We'll just stick with the one strategy.

In this situation, Warden's told that it should use the `password` strategy,
which is defined in `config/initializers/warden/strategies/password.rb`. This
strategy is defined like this:

```ruby
Warden::Strategies.add(:password) do
  def valid?
    params["username"].present? && params["password"].present?
  end

  def authenticate!
    u = User.find_by(username: params["username"])
    u.try(:authenticate, params["password"]) ? success!(u) : fail!
  end
end
```

So there's the two parts to it that matter crucially: we've defined the
`Warden::Manager` as being a middleware for the application and we've told it
"pretty please use the password strategy whenever you feel like authenticating
a user". Cool.

The `valid?` method is called when the strategy is used to determine if the
strategy would be a valid one to use in a particular authentication context. In
our case, this strategy _is_ valid, just as long as `params` includes both of
"username" and "password".

The `authenticate!` method is called when the strategy wants to attempt an
authentication. Inside this method, we attempt to find a user and then to
authenticate that user with the `has_secure_password` method `authenticate`. If
the authentication is successful, then we call the Warden-supplied method
`success`. If the user isn't found or the authentication does not succeed, then
we call the `fail!` method.

## The Rails application

So then you have a login form at `app/views/login/new.html.erb` inside this
application which contains a `username` and `password` field. Here's that form:

```erb
<%= form_with url: '/login' do |f| %>
  <p>
    <%= f.label :username %>
    <%= f.text_field :username %>
  </p>

  <p>
    <%= f.label :password %>
    <%= f.text_field :password %>
  </p>

  <%= f.submit %>
<% end %>
```

Simple enough.

This form posts to `/login`, and if you look in `config/routes.rb` you'll see
the route is defined like this: 

```ruby
get '/login', to: 'login#new'
post "/login", to: "login#login"
```

So that means that any time this form is submitted it will (hopefully) go to
the `login` action inside `LoginController`. That action looks like this:

```ruby
def login
  # Reset session
  warden.reset_session!
  user = warden.authenticate

  if user
    warden.set_user(user)
    redirect_to logged_in_path
  else
    flash[:alert] = "Failed to login"
    render :login
  end
end

def logged_in
  user = warden.user
  render plain: "You are logged in as #{user.username}"
end

private

def warden
  request.env['warden']
end
```

And here's your first real taste of what warden does. The `request.env['warden']`
object is a warden proxy object that acts as the gateway to all things
authentication within your application. The `request.env` comes from Rack, but the
`request.env['warden']` thing comes from the `Warden::Manager` middleware. That
middleware has "injected" a thing called "warden" into the request's
environment.

On the first (real) line of this controller, `env['warden'].reset_session!` is
called which will reset the warden session every time the login form is
submitted. We'll cover more about the session later on.

The `env['warden'].authenticate` call in this action is where the real magic
happens though. The `authenticate` method will tell Warden to look through all
its *valid* strategies and attempt to authenticate a user against each one until it
works. If no strategy is valid, then you're out of luck. If no strategy allows
the user to be authenticated, then you're out of luck again.

By "valid", I mean that it passes the `valid?` method test for the defined
strategy (which is inside `config/application.rb`, remember?). If it *does* pass
that, then it'll call the `authenticate!` method on that strategy, running the
code inside it.

If the authentication is successful, then it will return the user (by way of the
`success!(u)` call in the strategy) and then the controller will know what user
just signed in. We can then tell Warden to remember this user for the duration
of their browser's session, which we do with the `set_user` method. Then we
redirect this user to the super-secret-special `logged_in_path`. This action
just tells the user their username.

If the authentication fails, then we render a `flash[:alert]` message and then
re-render the login page.

## Session serialization

Let's take another look at the `Warden::Manager` configuration in
`config/application.rb`:

```ruby
config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :password

  manager.serialize_into_session do |user|
    user.id
  end

  manager.serialize_from_session do |id|
    User.find(id)
  end
end
```

The `serialize_into_session` and `serialize_from_session` methods are two that
we haven't talked about yet. 

When we call `set_user`, Warden invokes the `serialize_into_session` block here
to know how to store the user's information in the session. This works to ensure that the application knows about the user every time they make a request to our application. This works through a few distinct steps:

1. We call `set_user` in the controller
2. The controller sends a response back to the user's browser, which tells the
   browser to store an _encrypted cookie_ on the user's machine. This cookie
   contains the user's ID.
3. When the user makes another request to our application, their browser sends
   the cookie back to us. We can then _decrypt_ the cookie -- done automatically
   by Rack -- then read out the user's ID. This is what `serialize_from_session`
   does for us.
4. Once we have the user's ID, then we can call `User.find(id)` to load that
   user's data from the database.

To access that user's information in the database, we can call
`request.env['warden'].user`, as we do in the `logged_in` action of the
`LoginController`.

So there you have it. A very quick run-through of how Warden authenticates users
within a Rails application.


