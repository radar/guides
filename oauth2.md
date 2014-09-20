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
    expect("#application_client_id").to eq(application.client_id)
    expect("#application_client_secret").to eq(application.client_secret)
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


# TODOs without homes:

* Add validations to OAuth::Application model
* Validate redirect_uris are absolute

## Authorize endpoint

### http://tools.ietf.org/html/rfc6749#section-3.1
### http://tools.ietf.org/html/rfc6749#section-4.1

## Token endpoint

### 4.1.1
### 4.2.1

