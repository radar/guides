# Creating an OAuth 2 provider in Rails

**Note**: The [doorkeeper gem](https://github.com/doorkeeper-gem/doorkeeper) can be used to provide features similar to what's in this guide. This guide is written for those who want to learn how to implement an OAuth 2 provider from scratch.

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

### The Authorization Screen

We're now at the first part of the OAuth authorization process: where the third-party app connects to our application and gets a user to grant them access to perform specific tasks on their behalf. This screen looks like this:

TODO: Screenshot

We arrive at this screen by having a third-party application redirect back to our application, using a URL like the one described in [Section 4.1.1](http://tools.ietf.org/html/rfc6749#section-4.1.1) or [Section 4.2.1](http://tools.ietf.org/html/rfc6749#section-4.2.1). For the sake of simplicity, we'll be focussing on just Section 4.1.1 for now. The example URL from that section looks like this:

```
GET /authorize?response_type=code&client_id=s6BhdRkqt3&state=xyz
    &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb
```

The third-party application redirects back to us and tells us it wants an authorization code by setting the `response_type` parameter to `code`. It tells us who it is, by providing us with the `client_id` that we gave it when it registered with us. The `redirect_uri` parameter here is entirely optional, but when it's  passed it must match the one registered with us. The `state` parameter is used to maintain state during the entire OAuth flow, verifying that requests are part of the same set. 

What's not shown here is the `scope` parameter, which tells our application what the third-party application would like access to. This typically looks something like `user list`, although some OAuth providers (such as GitHub), separate their values with commas, i.e. `user,list`. This is a mild violation of the spec, but nobody cares enough to make a big deal of it. The difference in code between splitting on spaces and splitting on commas is only one character.

Let's look at that authorization screen again with all that in mind:

TODO: Screenshot

In this screenshot, we can see what application is requesting what permissions from the current user. The third-party application information has come from the `client_id` parameter in the request, and the scopes are sourced from the same spot.

When the user clicks 'Allow' on this screen, we'll grant the specified third-party application an auth token, and redirect the user back to the third-party application. The third-party application uses the granted auth token to request an access token, and from there on they can use this token to access our API endpoints.

If the user clicks 'Deny', we will *not* grant them an auth token, but instead redirect to the third-party application with a very specific message that indicates that the user refused access.

Let's focus on the happy path of a user allowing access first. When a third-party redirects back to us, we want to show that screen to our users. In order to ensure that this works correctly, we're going to need to update the code in `spec/features/oauth/authorize_spec.rb`. The first thing that we'll do is we'll add an application `let` block:

```ruby
let(:application) do
  Oauth::Application.create!(
    name: "Test Application",
    owner: "Tester",
    redirect_uri: "http://client.example.com/oauth/callback"
  )
end
```

We need to do this so that we can navigate to the authorize endpoint and pass it in the `client_id` from this application. Rather than repeating ourselves everywhere when we want a valid URL to our authorization endpoint, we'll set this up in `let` block as well:

```ruby
let(:authorize_url) do
  oauth_authorize_url(
    client_id: application.client_id,
    response_type: 'code'
  )
end
```

We can now use this in both of our tests instead of calling `oauth_authorize_url` there:

```ruby
context "when not signed in" do
  it "prompts the user to sign in" do
    visit authorize_url
    expect(page.current_url).to eq(new_user_session_url)
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    expect(page.current_url).to eq(authorize_url)
  end
end
```

And the other one:

```ruby
context "when signed in" do
  before do
    login_as(user)
  end

  it "allows the user to proceed" do
    visit authorize_url
    expect(page.current_url).to eq(authorize_url)
  end
end
```

We should validate that these changes so far have not broken our test. Let's run them again.

```
2 examples, 0 failures
```

That's a good start. Now we want to validate that when a user visits this page, they see who they're granting permission to. Let's edit that second test to now look like this:

```ruby
context "when signed in" do
  before do
    login_as(user)
  end

  it "allows the user to proceed" do
    visit authorize_url
    expect(page.current_url).to eq(authorize_url)
    expect(page).to have_content("The application '#{application.name}' by '#{application.owner}' would like permission to:")
  end
end
```

That's a good start, but what would the application like permission to do in particular? That part is granted by the `scope` parameter, which we've not specified in our definition of `authorize_url`. Let's jump back to that and add a `scope` parameter to it:

```ruby
let(:authorize_url) do
  oauth_authorize_url(
    client_id: application.client_id,
    response_type: 'code',
    scope: 'user list'
  )
end
```

The `scope` parameter here will (eventually) grant the third-party application in this instance access to see the user's information and to list devices. We now need to verify that these scopes appear on our page too. Let's change that test one more time:

```ruby
context "when signed in" do
  before do
    login_as(user)
  end

  it "allows the user to proceed" do
    visit authorize_url
    expect(page.current_url).to eq(authorize_url)
    expect(page).to have_content("The application '#{application.name}' by '#{application.owner}' would like permission to:")
    within("#scopes") do
      expect(page).to have_content("View your contact details")
      expect(page).to have_content("List your devices")
    end
  end
end
```

Finally, we'll need a way to let the user allow or deny this third-party access. For that, we'll have two buttons called "Allow" and "Deny", which we can check for by adding this code to the bottom of the test:

```ruby
buttons = all("input[type='submit']")
expect(buttons.map(&:value)).to match(['Allow', 'Deny'])
```

That'll do for now. We've got three things to do here: show the third-party application's information, show a list of scopes, and provide buttons for allowing or denying access to the user's resources.

When we run this test with `bundle exec rspec spec/features/oauth/authorize_spec.rb`, we'll see this:

```
Failure/Error: expect(page).to have_content(
  "The application '#{application.name}' by '#{application.owner}' would like permission to:"
)
  expected to find text 
    "The application 'Test Application' by 'Tester' would like permission to:"
  in "TODO"
```

When we added the `authorize` action to `Oauth::EndpointsController, we wrote just this:

**app/controllers/oauth/endpoints_controller.rb**

```ruby
class Oauth::EndpointsController < ApplicationController
  before_filter :authenticate_user!

  def authorize
    render text: 'TODO'
  end
end
```

This won't suffice now, as we're going to need to display the information that our test needs. Currently, all it requires is the application's information. To get that, we'll fetch the application from the database by changing the action to this:

```ruby
def authorize
  @application = Oauth::Application.find_by(client_id: params[:client_id])
end
```

Now that we've changed the action like this, we're going to need a view. Let's create one:

**app/views/oauth/endpoints/authorize.html.erb**

```erb
<strong>The application '<%= @application.name %>' by '<%= @application.owner %>' would like permission to:</strong>
```

With this view now in place, our test should get a little further when we run it again:

```
Failure/Error: within("#scopes") do
Capybara::ElementNotFound:
  Unable to find css "#scopes"
```

This time, it's looking for the list of scopes. These are the scopes that the third-party application is asking the user for. In order to render these on the page, we're going to need to parse the `scope` parameter sent through in the request, which in this case is `user list`, which means that the third-party application wants access to the user's details, as well as the ability to list their devices. 

We'll need to convert the `user list` scope parameter into something human readable. To do that, we'll need a way of mapping the scope values to their human readable counterparts, which can be a new method in the controller, defined underneath the `authorize` method:

**app/controllers/oauth/endpoints_controller.rb**

```ruby
private

def potential_scopes
  @potential_scopes ||= {
    'user' => 'View your contact details',
    'list' => 'List your devices'
  }
end
```

Now that we have a way of mapping them, let's do the conversion in the `authorize` action:

```ruby
def authorize
  @application = Oauth::Application.find_by(client_id: params[:client_id])
  @scopes = params[:scope].split(" ").map { |s| potential_scopes[s] }
end
```

This code will loop through the scopes in `params[:scope]` and find the matching scopes from the `potential_scopes` method. We can now use that `@scopes` variable in the view for this action to show the user the list of scopes:

**app/views/oauth/endpoints/authorize.html.erb**

```erb
<ul id='scopes'>
  <% @scopes.each do |scope| %>
    <li><%= scope %></li>
  <% end %>
</ul>
```

This should be enough to progress our test one step further. Let's run them again and see.

```
Failure/Error: expect(buttons.map(&:value)).to match(['Allow', 'Deny'])
  expected [] to match ["Allow", "Deny"]
```

Indeed! The only thing that is now missing on this page is the buttons for the user to either allow or deny the third-party application. Just adding buttons isn't going to be enough to make this functional though, we'll need to have a form wrapped around those buttons. That form needs to submit its data back to our application so that the application knows what to do next. If the user clicks "Allow", then the application should redirect the user to the third-party application with an auth token. If they click "Deny", it should still redirect the user to the third-party application, but with an error message instead of an auth token. Also, in order to know what application to redirect to, we'll need to pass at least the `client_id` back to the application. We will also need to pass the `state` and `scope` parameters as well.

With all that in mind, let's add the code to our view:

**app/views/oauth/endpoints/authorize.html.erb**

```erb
<%= form_tag oauth_create_authorization_url(params.slice(:client_id, :state, :scope)) do %>
  <%= submit_tag "Allow" %>
  <%= submit_tag "Deny" %>
<% end %>
```

We're using `oauth_create_authorization_url` here instead of `oauth_authorize_url` here because it's a good practice to separate the actions in our controller that set up the form and accept the form's information. Therefore we'll have this `authorize` action set up the form, and a different action called `create_authorization` accept it. We'll need to add this route to our routes file before we can continue, adding it inside the `namespace :oauth` block:

**config/routes.rb**

```ruby
post '/authorize', to: 'endpoints#create_authorization', as: 'create_authorization'
```

This form submits back to the `create_authorization` endpoint in our application with four things, the `client_id`, `state`, `scope` and `commit` parameters. The `commit` parameter will be either "Allow" or "Deny", depending on what button the user pressed. We'll handle those parameters in the next step. First, we should verify that the addition of this form makes our tests pass by running them again:

```
2 examples, 0 failures
```

Great, we've got the form now displaying the correct information and actions to the user. The user can see which application is requesting what permissions, and then they can choose to "Allow" or "Deny" that application. 

### Redirecting back to the third-party application

Once a user has made their choice, we need to redirect them back to the third-party and give them the good (or bad) news. To make sure this works correctly, we'll write even more tests. To simulate a user clicking the button, typically we would write an integration test which would navigate to the authorization page, then verify that when "Allow" was clicked it redirected the user out to the third-party. This is not going to be particularly easy, because we don't have a third-party to redirect to! So instead we will just write controller tests which can be used to easily test this behaviour.

The first controller test we'll write is for the happy path; when a user clicks "Allow" and permits a third-party application to access our API on the user's behalf. The action that we need to undertake once that "Allow" button has been clicked is documented in [Section 4.1.2 of the RFC](http://tools.ietf.org/html/rfc6749#section-4.1.2). This is the resposne we need to be returning according to that section:

```
HTTP/1.1 302 Found
Location: https://client.example.com/cb?code=SplxlOBeZQQYbYS6WxSbIA
          &state=xyz
```

The `code` parameter in this request is an authorization code, which the third-party application can use to make a request for an access token. When it makes that request, it needs to pass back the code, its `client_id` and `client_secret`. If all the parameters are valid, then our application will grant them an access token.

For that feature to work, we will need to store the auth tokens in our database, which will mean that we will need a model for them at some point in the very near future. Let's create this model by using this command:

```
rails g model oauth/auth_token token:string scope:string application_id:integer user_id:integer
```

Auth tokens in our system will be 32-character hexadecimal strings. We need to track the `scope` attribute so that we can copy that information over to our access token records once they're created. These auth tokens need to be linked to applications and users so that we know which application has access to what user's resources. Let's run the migrations now to create the `oauth_auth_tokens` table in our database:

```
rake db:migrate
```

Now that we have a model, let's write a test for the happy-path of `Oauth::EndpointsController#authorize`:

**spec/controllers/oauth/endpoints_controller_spec.rb**

```ruby
require 'rails_helper'

RSpec.describe Oauth::EndpointsController do
  let(:application) do
    Oauth::Application.create!(
      name: 'Test application',
      owner: 'Some owner',
      redirect_uri: 'http://client.example.com/oauth/callback'
    )
  end

  context "authorize" do
    context "with valid params" do
      let(:params) do
        {
          response_type: 'code',
          client_id: application.client_id,
          scope: 'user list',
          commit: 'Allow',
          state: 'abc1234'
        }
      end

      it "redirects to the client with an auth token" do
        expect do
          post :create_authorization, params
        end.to change { application.auth_tokens.count }.by(1)

        redirect_url, redirect_params = response.redirect_url.split("?")
        expect(redirect_url).to eq(application.redirect_uri)

        redirect_params = Rack::Utils.parse_query(redirect_params)
        expect(redirect_params["code"]).to match(/[a-f\d]{32}/)
        expect(redirect_params["state"]).to eq('abc1234')
      end
    end
  end
end
```

There are a couple of things that need setting up before we get to the meat of our test. First of all, we need to set up an application. This is the application that has requested permission from the user and the application that will be granted an authorization token because the user has clicked 'Allow'. That's a bit of a spoiler for the next part, where we're setting up the `params` that will be used in our request.

Then it's time for the meat of the test. Rather than have the logic that sets up the form and the logic that accepts the form's data and parses it in the one action, we're going to split it into two. This is why we're using a `POST` request to the `create_authorization` action instead of the `authorize` action.

Next, we have a couple of expectations. The first is that the application's auth tokens count should increase by one after the user has clicked 'Allow'. This indicates that we have granted the application an authorization token. The remaining expectations in this test validate that the URL that the user is redirected to matches the application's `redirect_uri` parameter, and that the redirect url contains two parameters: the `code` which will be the `token` attribute from the authorization token, and the `state` parameter which will match the state as it was passed in to the request.

When we run this test with `bundle exec rspec spec/controllers/oauth/endpoints_controller_spec.rb`, we'll see this:

Failure/Error: end.to change { application.auth_tokens.count }.by(1)
     NoMethodError:
       undefined method `auth_tokens' for #<Oauth::Application:...>
```

It appears that we're missing the `auth_tokens` association on the `Oauth::Application` model. We didn't add this when we generated the `Oauth::AuthToken` model and now we're paying the price. Let's add this association now:

**app/models/oauth/application.rb**

```ruby
class Oauth::Application < ActiveRecord::Base
  before_create :generate_client_tokens

  has_many :auth_tokens

  private

    def generate_client_tokens
      self.client_id = SecureRandom.hex(16)
      self.client_secret = SecureRandom.hex(32)
    end
end
```

When we run our test again, it will fail for a new reason:

```
Failure/Error: post :authorize, params
NoMethodError:
  undefined method `authenticate!' for nil:NilClass
  # .../gems/devise-3.3.0/lib/devise/controllers/helpers.rb:112:in `authenticate_user!'
```

This error is caused by Devise expecting there to be an object available at `env['warden']` in our controller that has an `authenticate!` method. Controller specs do not automatically come with such a thing, and so Devise is freaking out. We can fix this by stubbing the `authenticate_user!` method in this context because we don't need it. We should add this directly above the `context "authorize"` block in our controller spec:


**spec/controllers/oauth/endpoints_controller_spec.rb**

```ruby
before do
  allow(controller).to receive(:authenticate_user!)
end
```

This small change will prevent the Devise version of the `authenticate_user!` method from ever being called. It's not important at all that it's called within this test of our controller, so we can safely do this.

When we run the test again, we'll finally see something that has to do with the test itself:

```
Failure/Error: expect do
  expected result to have changed by 1, but was changed by 0
```

This error is happening on the block of code in our test that expects the application's auth token count to increase by 1:

```ruby
expect do
  post :authorize, params
end.to change { application.auth_tokens.count }.by(1)
```

The test is failing because we're not creating any auth tokens at all. To fix this expectation for our test, we'll need to start doing that. Let's define the `create_authorization` method in our controller:

**app/controllers/oauth/endpoints_controller.rb**

```ruby
def create_authorization
  @application = Oauth::Application.find_by(client_id: params[:client_id])
  @application.auth_tokens.create!
end
```

We're now creating auth tokens for the application, which should fix that error that we were seeing. When we run our test again, we'll see a different error:

```
Failure/Error: post :create_authorization, params
ActionView::MissingTemplate:
  Missing template oauth/endpoints/create_authorization, application/create_authorization with ...
  Searched in:
    * ...
```

This error is happening because the `create_authorization` action is falling to the default behaviour of attempting to render a template. We don't want it to render a template in this instance; we want it to redirect back to the application's `redirect_uri` with some parameters. So let's start implementing that.

**app/controllers/oauth/endpoints_controller.rb**

```ruby
def create_authorization
  @application = Oauth::Application.find_by(client_id: params[:client_id])
  auth_token = @application.auth_tokens.create!
  redirect_params = Rack::Utils.build_query({
    code: auth_token.token,
    state: params[:state]
  })
  redirect_to @application.redirect_uri + "?" + redirect_params
end
```

This action is now creating an authorization token for the application and then redirecting the user back to the third-party application's `redirect_uri`, with the `code` and `state` parameters. That's our end of the bargain done -- at least for this part. When we run the test again, we'll see this:

```
Failure/Error: expect(redirect_params["code"]).to match(/[a-f\d]{32}/)
  expected nil to match /[a-f\d]{32}/
```

The action is now correctly redirecting instead of rendering, but the `code` parameter is `nil`, instead of the expected 32-character token we're expecting. This is because when we create an `Oauth::AuthToken` instance, we're not assigning its `token` attribute at all. To fix that, we'll use a `before_create` in that model:

**app/models/oauth/auth_token.rb**

```ruby
class Oauth::AuthToken < ActiveRecord::Base
  before_create :generate_token

  private

  def generate_token
    self.token = SecureRandom.hex(16)
  end
end
```

This new `generate_token` method will be called directly before any `Oauth::AuthToken` is created in the database. By doing it this way, we can ensure that every `Oauth::AuthToken` instance has a `token` set. When we run the test once again, we'll now see a green dot where there once was a red F:

```
1 example, 0 failures
```

This is great. This means that the `create_authorization` method is doing exactly as the OAuth spec suggests: creating a code and storing it, and then redirecting back to the third-party application.

Before we continue onwards on our implementation journey, let's tidy up the code in the controller. There's now some duplication in the two actions:

**app/controllers/oauth/endpoints_controller.rb**

```ruby
def authorize
  @application = Oauth::Application.find_by(client_id: params[:client_id])
  @scopes = params[:scope].split(" ").map { |s| potential_scopes[s] }
end

def create_authorization
  @application = Oauth::Application.find_by(client_id: params[:client_id])
  auth_token = @application.auth_tokens.create!
  redirect_params = Rack::Utils.build_query({
    code: auth_token.token,
    state: params[:state]
  })
  redirect_to @application.redirect_uri + "?" + redirect_params
end
```

The `@application` instance variable is being defined in exactly the same way in both actions. Rather than keeping that code there, we'll move it to a private method in the controller:

**app/controllers/oauth/endpoints_controller.rb**

```ruby
def authorize
  application
  @scopes = params[:scope].split(" ").map { |s| potential_scopes[s] }
end

def create_authorization
  auth_token = application.auth_tokens.create!
  redirect_params = Rack::Utils.build_query({
    code: auth_token.token,
    state: params[:state]
  })
  redirect_to application.redirect_uri + "?" + redirect_params
end

private

def application
  @application ||= Oauth::Application.find_by(client_id: params[:client_id])
end
```

That's better. We've made our controller a little neater. When we run our tests again, they should still be green:

```
1 examples, 0 failures
```

Yes indeed they are. Now wasn't that a good fun exercise in "Red, Green Refactor?". We've now implemented [Section 4.1.2](http://tools.ietf.org/ht.l/rfc6749#section-4.1.2) of the RFC.

You might be thinking that the work on the `authorize` and `create_authorization` endpoints is done. You'd be less than 33% correct. There's still a couple of things that we need to do before we can move onto the access token endpoint.



The first of these is the next section in the RFC: [Section 4.1.2.1](http://tools.ietf.org/html/rfc6749#section-4.1.2.1). This section dicates that when a redirection URL is "missing, invalid or mismatching", we should inform the user of the error and we "MUST NOT" redirect the user back to that URL. Therefore we should be checking the `redirect_uri` for these things and responding as per the RFC.

The second thing covered in Section 4.1.2.1 is that when a user clicks "Deny", we need to follow the guidelines laid out in that section. Namely we need to not generate an authorization token but instead to redirect the user back to the third-party application with an error. There are other cases where can return an error, and so we will write tests for those too.

The third is documented in [Section 4.2.1](http://tools.ietf.org/html/rfc6749#section-4.2.1). The authorization endpoint can act differently if it receives a `response_type` of "token". When this happens, the `create_authorization` endpoint should generate an access token and not an auth token.

Let's focus on the first scenario for now, and then move onto the second one.

### Redirection URL is invalid

### Access denied

When a user clicks "Deny" instead of "Allow", our application must still redirect back to the third-party application. Instead of returning a `code` parameter, it should return an `error` parameter. 


## Token endpoint

### 4.1.3

## Implicit grants

### Section 4.2.1 (authorization endpoint granting access token)

## Refresh tokens

### Section 6

## Authenticating with the API

### User endpoint

### The three other actions


# TODOs without homes:

* Validate redirect_uris are absolute
