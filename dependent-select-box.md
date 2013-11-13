# Dependent Select Box Example

This guide is written to explain the code behind my [selector](https://github.com/radar/selector) application, which is also visible on Heroku at http://radar-selector.herokuapp.com.

This application only allows for CRUD operations on addresses. On the addresses form, there are two fields, one for country and one for state:

![New address page](/selector/new-address.png)

Changing the country will automatically update select box for states to be the states for that country.

### Lay of the land

Here's the models and their relationships with each other:

**app/models/address.rb**

```ruby
class Address < ActiveRecord::Base
  belongs_to :country
  belongs_to :state 
end
```
**app/models/country.rb**

```ruby
class Country < ActiveRecord::Base
  has_many :states
end
```

**app/models/state.rb**

```
class State < ActiveRecord::Base
  belongs_to :country, :touch => true
end
```

The only stand out thing in these models is the `:touch => true` option on the `belongs_to` 

This page is rendered by the `new` action within `AddressesController`, which contains this code:

```ruby
def new
  @address = Address.new
  collect_form_data
end
```

Typical `new` action with a bit of a twist on the end: the `collect_form_data` method. That method is defined at the bottom of the controller like this:

```ruby
def collect_form_data
  @countries = Country.order("name ASC")
  if @address.country
    @states = @address.country.states
  else
    @states = @countries.first.states
  end
end
```

This method collects all the data that the form needs to display. The form first of all needs a list of countries. If the `@address` object has a country assigned, then we will show the states from that country. Otherwise, we'll just show the states from the first country in the list. The only situation where a country will be assigned to an address is within the `edit` action of this controller.

The data from the `new` action along with the `collect_form_data` is then passed to the view at `app/views/addresses/new.html.erb` which is extremely simple:

```erb
<h2>New Address</h2>
<%= render "form" %>
```

The form partial (`app/views/addresses/_form.html.erb`) contains the meat of this view:

```erb
<%= form_for @address do |f| %>
  <p>
    <%= f.label :country_id %><br>
    <%= f.select :country_id, @countries.map { |c| [c.name, c.id] } %>
  </p>

  <p> 
    <%= f.label :state_id %><br>
    <%= f.select :state_id, @states.map  { |s| [s.name, s.id] } %>
  </p>

  <%= f.submit :class => "btn btn-primary" %>
<% end %>
```

This contains two fields, one for the country and one for the state. The `@countries` is a list of all countries, where `@states` is going to be just the states for the first country in that list. Changing the country in the list will, by something that seems like magic, update the list of states.

### Updating a select box using JavaScript

It's not magic. It's just JavaScript.

In `app/assets/javascripts/addresses.js.coffee` we start with this code:

```coffee
$(document).ready ->
  state_cache = {}
  $('#address_country_id').change ->
    country_id = $(this).val()
    if state_cache[country_id]
      populate_states(state_cache[country_id])
    else
      $.get('/states?country_id=' + country_id, (states) ->
        state_cache[country_id] = states
        populate_states(state_cache[country_id])
      )
```

This is the most complex piece of code within the application. It looks intimidating but really it's not so bad. On the first line, we wait until the document is ready. Once it's ready, we define a `state_cache` object where we're going to store a list of states for each country as we receive them.

We then hook into the `change` event on the `#address_country_id` element, which is the Country select box from our form. We get the value from this form and then check to see if the cache contains any states for that country yet. It won't on the first request for this country, but it will on the second. If it does, we call `populate_states`.

If the cache for that country does not return any states, then we make a request to the application to `/states`, passing in a `country_id` parameter. This route is defined within `config/routes.rb` like this:

```ruby
get '/states', :to => 'states#index'
```

This controller is at `app/controllers/states_controller.rb`:

```ruby
class StatesController < ApplicationController
  respond_to :json

  def index
    country = Country.find(params[:country_id])
    respond_with(country.states) if stale?(country)
  end
end
```

This controller responds with `json` by default, which is helpful because JavaScript is really adept at reading JSON. In the `index` action of this controller, we find the country that was requested and then respond with a list of that country's states.

The `stale?` method here will return a 304 response from the server if the browser has seen this page before,  and the browser will use its own cache to return the JSON. Otherwise the server will return a 200 status with the JSON from the action.

Once the action returns the data, this code is run back in `app/assets/javascripts/addresses.js.coffee`:

```coffee
$.get('/states?country_id=' + country_id, (states) ->
  state_cache[country_id] = states
  populate_states(state_cache[country_id])
)
```

This code stores the states within `state_cache` so that if this country is ever requested again it's just a very quick client side lookup and there's no requests sent back and forth between the browser and the server. Finally, the `populate_states` function is called. This is defined like this:

```coffee
populate_states = (states) ->
  $('#address_state_id').html("")
  for state in states
    $('#address_state_id').prepend("<option value='" + state.id + "'>" + state.name + "</option>")
```

This function takes a list of the states that we've received, clears all the options within the State select field and replaces them with new options made up from that list of states.

That's all there is to this. It's not magic, it's just a bit of smart CoffeeScript and some smart Rails code too.
