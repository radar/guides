# Banana, A Warden Example Application

cjz was all like "bros, teach me the way of the Warden". And we said unto him
"lol, like use Devise". But cjz refused. Some say it was a gallant refusal.
Others said he was crazy. The third group asked "who the fuck is cjz?". And
then it was so.

Thus, I spent some time battling the beast known as Warden to produce this
application. Gaze unto it's soft, gooey center to understand how you too can
use Warden by itself within a Rails app.

## omg there is code and I don't know what it does

*Everybody be cool.*

Warden works by placing a thing called "middleware" in the "rack stack" for
your application. There's a whole bunch of middleware that make up a Rails
application, and you can view these by running the `rake middleware` command.
A little known fact.

A request headed for your application goes through this middleware stack piece
by piece and those pieces of middleware can modify the request (or in Rack
parlance, it's called an "environment") in certain ways by adding headers,
modifying content and other fun things. They can even stop the request in its
tracks and return a response immediately.

This particular piece of middleware, `Warden::Manager`, is provided by the
warden gem which you may know from such places as the `Gemfile` of this
application, and as a major component in how Devise works. This middleware is
configured like this inside `config/application.rb`:

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

Warden uses a thing called *strategies* for authentication. They're like
*battle plans* for authentication. In this situation, Warden's told that it
should use the `password` strategy, which is also defined inside
`config/application.rb`, but would probably be better placed into
`config/initializers/warden/strategies/password.rb`... anyway. More about the strategy later on.

The rest of the code in this block is all to do with the serialization of the user. Warden needs to remember the User, but it can't go and save the *whole damn User object* into the session, because that might cause the session to overflow and we definitely don't want that. To avoid that, all we save to the session is the ID of the user. When we want our User back, we just call `User.find`. Wow, isn't that cool?

Now, back to the *strategic strategy*. This strategy is defined like this:

```ruby
Warden::Strategies.add(:password) do

  def valid?
    params["username"] || params["password"]
  end

  def authenticate!
    u = User.authenticate(params["username"], params["password"])
    u.nil? ? fail! : success!(u)
  end
end
```

So there's the two parts to it that matter crucially: we've defined the
`Warden::Manager` as being a middleware for the application and we've told it
"pretty please use the password strategy whenever you feel like authenticating
a user". Cool.

The `authenticate` method in the `User` model goes like this:

```ruby
  def self.authenticate(username, password)
    user = find_by(:username => username)
    user.authenticate(password) if user
  end
```

We could go ahead and define the `authenticate` method ourselves, or we could rely on the tried-and-true `has_secure_password`-provided methods. Call this truly magnificient method underneath the `class` definition:

```ruby
class User < ActiveRecord::Base
  has_secure_password
```

Now users have secure passwords. Isn't that magical? These wonderful security features are provided by the `bcrypt` (or `bcrypt-ruby`, I can never remember which) gem, so don't forget to add that to your Gemfile:

```ruby
gem 'bcrypt'
# OR
gem 'bcrypt-ruby'
```

 A small caveat here: you'll need to add a `password_digest` field to the `users` table:

```bash
rails g migration add_password_digest_to_users password_digest:string
```

This field is where the passwords will be securely stored to. They won't be in a format that anyone could (probably) read, so that's great. 

Don't forget to run this migration or else there will be BIG TROUBLE!

```
rake db:migrate
```

## more code

So then you have a login form at `app/views/login/new.html.erb` inside this
application which contains a `username` and `password` field. Simple enough. 
This form posts to `/login`. After it does this, users who have the right credentials should be signed in.

The form probably looks like this:

```ruby
  <%= form_tag '/login' do %>
    <p>
      <%= label_tag "username" %><br>
      <%= text_field_tag "username" %>
    </p>

    <p>
      <%= label_tag "password" %><br>
      <%= password_field_tag "password" %>
    </p>
  <% end %>
```

 and if you look in `config/routes.rb` you'll see
the route is defined like this: 

```ruby
post '/login', :to => "login#login"
```

So that means that any time this form is submitted it will (hopefully) go to
the `login` action inside `LoginController`. That action looks like this:

```ruby
def login
  # Reset session
  env['warden'].logout
  if env['warden'].authenticate
    render :text => "success"
  else
    render :text => "failure"
  end
end
```

And here's your first real taste of what warden does. The `env['warden']`
object is a warden proxy object that acts as the gateway to all things
authentication within your application. If you tell it to logout, it'll logout
the current session. If you tell it to authenticate, then it'll authenticate
it.

On the first (real) line of this controller, the aforementioned `env['warden'].logout` is called which will reset the warden session every time the login form is submitted.

The `env['warden'].authenticate` call in this action is where the real magic
happens though. The `authenticate` method will tell Warden to look through all
its *valid* strategies and attempt to authenticate a user against each one until it
works. If no strategy is valid, then you're out of luck. If no strategy allows
the user to be authenticated, then you're out of luck again.

By "valid", I mean that it passes the `valid?` method test for the defined
strategy (which is inside `config/application.rb`, remember?). If it *does* pass
that, then it'll call the `authenticate!` method on that strategy, running the
code inside it.

For the strategy that this app has, it calls the `User.authenticate` method,
defined inside `app/models/user.rb`, and then if that returns a user, then it
calls `success!` for the strategy and if there is no user then `fail!`.

What will happen then is that if it's successful, `env['warden'].authenticate`
will return the newly authenticated-and-signed-in `User` object which will mean
then that the controller will render "success". If it isn't successful, then it
will render "failure".

Before you can actually log in as a user, it's going to be extremely necessary to create a user, which youcan do in `rails console`:

```ruby
User.create(
  :email => "you@example.com",
  :password => "password",
  :password_confirmation => "password"
)
```

Remember that old `has_secure_password` call in our User model? Well, that'll take those `password` and `password_confirmation` parameters, confirm that they're indeed the same thing and then if they are, it will hash the password using the functions provided by the `bcrypt` gem, which `has_secure_password` depends on.


### Fin.

This has been another deliriously educational wall-o-text by me. I hope you
enjoyed it.

