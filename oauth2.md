# Creating an OAuth 2 provider in Rails

**Note**: The [doorkeeper gem](https://github.com/doorkeeper-gem/doorkeeper) can be used to provide features similar to what's in this guide. This guide is written for those who want to learn how to implement an   provider from scratch.

OAuth 2 is best described by the Abstract in [RFC6749: "The OAuth2 Authorization Framework"](http://tools.ietf.org/html/rfc6749):

> The OAuth 2.0 authorization framework enables a third-party
> application to obtain limited access to an HTTP service, either on
> behalf of a resource owner by orchestrating an approval interaction
> between the resource owner and the HTTP service, or by allowing the
> third-party application to obtain access on its own behalf. 

[RFC6749](http://tools.ietf.org/html/rfc6749) will be referred to constantly in this guide, as it documents how the whole framework works. The first section of the RFC is well worth a read, as it explains some common terms and really sets the scene for the rest of the document.

By the end of this guide, we'll have an OAuth 2 provider built into a Rails app which will allow third-party applications to obtain access to specific API endpoints within our application. We'll be using the [cloud_app](https://github.com/radar/cloud_app) repo as a base for this application. The cloud_app application is currently very lightweight, implementing an API that provides three actions for devices, listing, turning on and turning off. We can see this if we run the tests with `bundle exec rspec spec --format documentation`:

```
Api::V1::DevicesController
  can list devices
  can turn on a device
  can turn off a device
```

These API endpoints are open to the world currently, which means that anybody can perform those actions. During the course of this guide we'll be locking them down so that only third-party applications who have an *access token* can access those endpoints. When those third-party applications use their access tokens, they'll only be able to access the devices they've been permitted to access.

When a third-party application asks for authorization through our OAuth endpoints, they'll be asking for permission to perform these actions. A third-party application can ask for all three abilities, or any combination of the three. OAuth refers to these as "scopes". When a third-party application asks for permission, it will send through a comma-separated list of scopes that wants permission for, and then the user will need to grant them access to perform those actions. For instance, a third party might request all three permissions by passing through a scope of `list,turn_on,turn_off`.

The flow that we'll be implementing in this guide is this:

1. The third-party application redirects to our application, requesting that a user grants them permission to perform the actions listed in the specified `scope` on our Devices API endpoints.
2. When the user grants permission, our application redirects back to the third-party application with an *authorization token*.
3. The third-party application makes a request to our application's token endpoint, with that *authorization token*, passing through a *Client Token* and a *Client Secret*, along with their *authorization token* in order to gain an *access token*.
4. This *access token* can then be used to access our Devices API, using the permissions specified in the initial request's `scope` parameter.

The first thing that we'll need to implement is the ability for third-party applications to register.

## Application registration

Third-party applications need to register on our application in order to be able to use our OAuth features. When a third-party application registers with our application, we'll give them a `client_id` parameter to use for authorization. When a third-party application redirects their users to our authorize endpoint, it will pass through the `client_id` parameter and we'll know which application is making the request. We can then show information about that client to the user, so that they know who they're authorizing for their devices.

TODO: Display a screenshot of the authorization form here.
TODO: mention fields name and owner

The third-party application must also register a `redirect_uri` so that we know where to send the user after they've chosen what to do on the authorization page.

Later on, when the third-party application makes a request to our token endpoint, they'll need to pass through a `client_secret` parameter. While the `client_id` parameter is left out in the open, the `client_secret` parameter **MUST** be kept secret from any users and is only ever communicated server-to-server over a secure TLS connection.

In order to track these applications, we'll need to store their information in the database. To get it there, we'll use a model that we'll call `OAuth::Application`. This model needs the fields `name`, `owner`, `redirect_uri`, `client_id`, and `client_secret`. Let's generate this model using this command:

```
rails g model oauth/application \
  name:string \
  owner:string \
  redirect_uri:string \
  client_id:string \
  client_secret:string
```

Rails will give this model a bad name (in a literal sense), calling it `Oauth::Application`. We'll just have to tolerate this for now, as it's too much work to call it by its proper name, `OAuth::Application`.

We should add some validations to this model before we do much else:

```ruby
  validates :name, presence: true
  validates :owner, presence: true
  validates :redirect_uri, presence: true
```

There's no real point in applications registering without these attributes. The `name` and `owner` attributes are for identifying purposes; a user wants to know who they're granting permission to. The `redirect_uri` is ultimately important as well, as that's the location where our application redirects the user after they allow or refuse an application authorization to their devices. Let's now continue adding the application registration feature.

In order for OAuth applications to register in our application, we're going to need a form for them to do that. Because we're diligent about our coding best practices, we're going to write a test.

**spec/features/oauth/applications_spec.rb**

```ruby
require "rails_helper"

RSpec.describe "OAuth applications" do
  it "can be registered" do
    visit new_oauth_application_path
    fill_in "Name", with: "Third Party Application"
    fill_in "Owner", with: "Third Party"
    fill_in "Redirect URI", with: "client.example.com/oauth/callback"
    click_button "Register"
    expect(page).to have_content("Your application has been registered successfully.")
    application = OAuth::Application.first
    application_client_id = find("#application_client_id").text
    expect(application_client_id).to eq(application.client_id)

    application_client_secret = find("#application_client_secret").text
    expect(application_client_secret).to eq(application.client_secret)
  end
end
```

When we run this test with `bundle exec rspec spec/features/oauth/applications_spec.rb`, it will fail:

```
Failure/Error: visit new_oauth_application_path
NameError:
  undefined local variable or method `new_oauth_application_path'
```

This is because we don't have a route defined for this yet. Let's define one:

**config/routes.rb**

```ruby
get '/oauth/applications/new', to: 'oauth/applications#new'
```

We'll need to generate a controller to serve this route too:

```
rails g controller oauth/applications
```

Next, we'll add the `new` action to the controller:

**app/controllers/oauth/applications_controller.rb**

```ruby
class Oauth::ApplicationsController < ApplicationController
  def new
    @application = OAuth::Application.new
  end
end
```

Next, the `new` template:

**app/views/oauth/applications/new.html.erb**

```erb
<h2>New Application<h2>

<%= form_for @application do |f| %>
  <p>
    <%= f.label :name %>
    <%= f.text_field :name %>
  </p>
  <p>
    <%= f.label :owner %>
    <%= f.text_field :owner %>
  </p>
  <p>
    <%= f.label :redirect_uri, "Redirect URI" %>
    <%= f.text_field :redirect_uri %>
  </p>
  <%= f.submit "Register" %>
<% end %>
```

This form asks the third-party application to provide its name and its owner's name so we can identify it on the authorize screen. The `redirect_uri` field is so that after the authorization process has been complete, we can make a new request to that URL to inform the third-party application of a result.

This form is going to need somewhere to submit to, so let's add a `create` action to the controller:

**app/controllers/oauth/applications_controller.rb**

```ruby
class Oauth::ApplicationsController < ApplicationController
  def new
    @application = Oauth::Application.new
  end

  def create
    @application = Oauth::Application.new(params[:application])
    if @application.save
      flash[:success] = 'Your application has been registered successfully.'
      redirect_to oauth_application_path(@application)
    end
  end
end
```

The `redirect_to` in the `create` action is going to go to a `show` action, which we'll need to add to our controller:

**app/controllers/oauth/applications_controller.rb**

```ruby
def show
  @application = Oauth::Application.find(params[:id])
end
```

This action is going to need a template too. We know from our test that this page is going to need an element called `#application_client_id` with an automatically generated `client_id` in it, and another one called `#application_client_secret` with the automatically generated `client_secret` attribute in it. These attributes are going to be unique to this application and they'll be used when the application sends a user to our authorization endpoint. With that in mind, we'll create a basic form of our template:

**app/views/oauth/applications/show.html.erb**

```erb
<h2><%= @application.name %></h2>

<dl>
  <dt>Client ID</dt>
  <dd id='application_client_id'><%= @application.client_id %></dd>
  <dt>Client Secret</dt>
  <dd id='application_client_secret'><%= @application.client_secret %></dd>
</dl>
```

When we run this test again, we'll see this:

```
Failure/Error: expect(application_client_id).to eq(application.client_id)

  expected: nil
       got: ""

  (compared using ==)
```

The `client_id` that we're supposed to be generating for the third-party application isn't currently being generated, so this part of our test is failing. The part that checks for the `client_secret` attribute will fail the same way too, so while we're fixing up the `client_id`, we'll fix up the `client_secret` too.

To generate these two attributes, we'll use a `before_create callback in our `Oauth::Application` model. Before we do that, we'll write some tests to ensure that these callbacks are working.

**spec/models/oauth/application_spec.rb**

```ruby
require 'rails_helper'

RSpec.describe Oauth::Application do
  context "a created object" do
    let(:application) { Oauth::Application.create }
    it "has a client_id" do
      expect(application.client_id).to match(/[a-f\d]{32}/)
    end

    it "has a client_secret" do
      expect(application.client_secret).to match(/[a-f\d]{64}/)
    end
  end
end
```

With these tests, we're checking that the `client_id` is a 32-character hexadecimal string and the `client_secret` is a 64-character hexadecimal string. When we run these tests with `bundle exec rspec spec/models/oauth/application_spec.rb`, they'll fail:

```
1) Oauth::Application a created object has a client_id
   Failure/Error: expect(application.client_id).to match(/[a-f\d]{32}/)
     expected nil to match /[a-f\d]{32}/
   # ./spec/models/oauth/application_spec.rb:7:in `block (3 levels) in <top (required)>'

2) Oauth::Application a created object has a client_secret
   Failure/Error: expect(application.client_secret).to match(/[a-f\d]{64}/)
     expected nil to match /[a-f\d]{64}/
   # ./spec/models/oauth/application_spec.rb:11:in `block (3 levels) in <top (required)>'
```

To generate these, we'll use a callback in the `Oauth::Application` model:

**app/models/oauth/application.rb**

```ruby
class Oauth::Application < ActiveRecord::Base
  before_create :generate_client_tokens

  private

    def generate_client_tokens
      self.client_id = SecureRandom.hex(16)
      self.client_secret = SecureRandom.hex(32)
    end
end
```

The `SecureRandom.hex` method will generate a hexadecimal string such as `eba490c282a8673036892052563518d9` when asked for 16 bytes, or `1e6607f94afad6c558ffd6270b7db5ee2896a7c24b810fef5c81ce54b04c2100` when asked for 32 bytes. If you run this in an `irb` session, you'll see different results (almost) every time:

```ruby
require 'securerandom'
SecureRandom.hex(16)
```

By using this mehtod, we can be sure to get a unique `client_id` and `client_secret` for each `Oauth::Application` record within our application. When we run these model tests again, they'll pass:

```
2 examples, 0 failures
```

Now that we've validated that `client_id` and `client_secret` are being generated, let's go back to our feature spec. Does that work? Let's run it again and find out.

```
1 example, 0 failures
```

It certainly does. This means that third-party applications can now register with us and begin using our application as an OAuth provider. The next step is to add our authorization endpoint so that those applications can begin the OAuth flow.

## Authorize endpoint

The authorize endpoint serves a single purpose: to provide a screen to the user asking if they want to authorize an application to access things on their behalf. When it's done, it will look like this.

TODO: Screenshot.

The [relevant part of RFC 6749 is Section 3.1](http://tools.ietf.org/html/rfc6749#section-3.1). The first thing this says is:

> The authorization endpoint is used to interact with the resource
  owner and obtain an authorization grant.  The authorization server
  MUST first verify the identity of the resource owner.  The way in
  which the authorization server authenticates the resource owner
  (e.g., username and password login, session cookies) is beyond the
  scope of this specification.

The other paragraphs in that section are worth keeping in mind too.

An *authorization grant* can be one of two things: an *auth token* or an *access token*. This depends on the `response_type` parameter requested by the third-party application, described in [Section 3.1.1](http://tools.ietf.org/html/rfc6749#section-3.1.1). The two values supported by default of `response_type` are `code` and `token`. If we use `code`, we'll get an auth token, and if we use `token` we'll get an access token.

Before we can do that, we "MUST first verify the identity of the resource owner". If we don't do this, then we don't know who the auth token or access token belongs to, and that's going to make things hard when we attempt to use the access token to authenticate a user on our API endpoint.  We can "verify the identity of the resource owner" by requiring a user to be signed in before they can begin the OAuth process. 

After we have done that, we'll begin adding the authorization endpoint to our application, adding support for both response types (`code` and `token`), and all the associated fun that comes with that.

### Requiring a user to sign in

Before a user can use our OAuth endpoint, they must be signed in. When a user has signed in, we'll be able to link an OAuth auth token -- and later an OAuth access token -- to their record in the database. This linking can be used to know which user is accessing our API.

To make sure that being signed in is a definite requirement, we'll write a couple of new tests:

**spec/features/oauth/authorize_spec.rb**

```ruby
require 'rails_helper'

RSpec.describe "OAuth authorization" do
  include Warden::Test::Helpers

  let(:user) do
    User.create!(
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  context "when not signed in" do
    it "prompts the user to sign in" do
      visit oauth_authorize_url
      expect(page.current_url).to eq(new_user_session_url)
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
      expect(page.current_url).to eq(oauth_authorize_url)
    end
  end

  context "when signed in" do
    before do
      login_as(user)
    end

    it "allows the user to proceed" do
      visit oauth_authorize_url
      expect(page.current_url).to eq(oauth_authorize_url)
    end
  end
end
```

With both tests, we're visiting the `oauth_authorize_path`. This will be the path helper generated for the authorization endpoint in our application. The difference is that in the first test we're not signing in at all, whereas in the second test we're using `Warden::Test::Helpers#login_as` to sign in as a user. 

In the first test, we should be redirected to the `new_user_session_url` and then be made to sign in. Once we're signed in, then we should be back on the `oauth_authorize_url`. In the second test, we are signed in, and so no redirection should take place.

When we run this test with `bundle exec rspec spec/features/oauth/authorize_spec.rb`, we'll see that we're missing our `oauth_authorize_url` helper:

```
Failure/Error: visit oauth_authorize_url
NameError:
  undefined local variable or method `oauth_authorize_url' for ...
```

To define this path helper, we'll change the `namespace :oauth` block in our `config/routes.rb` file to this:

**config/routes.rb**

```ruby
namespace :oauth do
  resources :applications
  get '/authorize', to: "endpoints#authorize", as: 'authorize'
end
```

This new `get` call will define a new path at `/oauth/authorize` that will route to `Oauth::EndpointsController`'s `authorize` action. The path helper will be available as `oauth_authorize_[path|url]` because the route has been defined within the `:oauth` namespace.

Let's generate this `Oauth::EndpointsController`:

```
rails g oauth/endpoints
```

We'll also need to define the `authorize` action within this controller too, with just a placeholder for now:

**app/controllers/oauth/endpoints_controller.rb**

```ruby
class Oauth::EndpointsController < ApplicationController
  def authorize
    render text: 'TODO'
  end
end
```

This action doesn't need to do anything yet because our tests don't require it. When we re-run those tests, we'll see that our first test is failing, but the second one is passing:

```
Failure/Error: expect(page.current_url).to eq(new_user_session_url)

  expected: "http://www.example.com/users/sign_in"
       got: "http://www.example.com/oauth/authorize"

  (compared using ==)
# ./spec/features/oauth/authorize_spec.rb:17:in `block (3 levels) in <top (required)>'
```

Great, just like we've planned. The first test is now failing as it should because we're not yet redirecting users away from `Oauth::EndpointsController#authorize` if they're not first authenticated.

To fix this test, we'll add a call to `authenticate_user!` from Devise as a `before_filter`:

**app/controllers/oauth/endpoints_controller.rb**

```ruby
class Oauth::EndpointsController < ApplicationController
  before_filter :authenticate_user!

  def authorize
    render text: 'TODO'
  end
end
```

By doing this, the controller will first check if the user is authenticated. If they aren't, then it will save the location of the current page to the session and redirect the user to the sign in page. Once the user has signed in, they will be redirected back to the saved page.

Let's see if this is working now by running our tests again:

```
2 examples, 0 failures
```

Great! Our `Oauth::EndpointsController` is now requiring a user to be signed in before they can access the action within that controller. 

Our next step is filling out this action to provide a form to the user, asking them to authorize the third-party application to access our API on the user's behalf.

### Authorizing third-party applications


### http://tools.ietf.org/html/rfc6749#section-3.1
### http://tools.ietf.org/html/rfc6749#section-4.1

## Token endpoint

### 4.1.1
### 4.2.1

## Refresh tokens

## Authenticating with the API


# TODOs without homes:

* Validate redirect_uris are absolute