# Admin Namespacing

There comes a time in every application's life where you want to separate what normal users can do with what users with special powers can do. More often than not, these users with special powers are referred to as "admins". These admins are granted permission to create new content on the site, whereas the normal user is not granted any such permission.

Therefore a distinction must be made in the code to demarcate who is a normal user, and who is an admin user. Many apps do this by having an `admin` attribute on the user which can be set to `true` for those users. Some other apps do this with a role-based system.

In the case of the application we'll be looking at today, Blorgh, it's the former. Blorgh is a very simple blogging application that has users that could potentially be admins. These admin users are allowed to create, update and delete posts, and the other users are not.

Let's clone Blorgh now:

    git clone git@github.com:radar/blorgh
    cd blorgh
    git checkout pre-admin-namespace

After cloning the app, we should make sure that we can run it. Let's run these commands to set it up:

```
bundle install
rake db:setup
rails s
```

In this state, Blorgh has only three models: a `Post` model, a `Comment` model and a `User` model. On the `User` model, there's an attribute called `admin` which determines if the user has the ability to create, edit or destroy posts within the application. This check is done in such views as `app/views/posts/show.html.erb`, like this:

```erb
  <% if admin? %>
    <%= link_to 'Edit Post', edit_post_path(@post) %> |
    <%= link_to 'Delete Post', post_path(@post), method: :delete %>
  <% end %>
```

The `admin?` helper is defined within `ApplicationController` like this:

```ruby
def current_user
  env['warden'].user
end
helper_method :current_user

def admin?
  current_user && current_user.admin?
end
helper_method :admin?
```

It first checks to see if the `current_user` method returns anything. If it does, then whatever is returned it checks to see if the `admin?` method on that object returns `true`. The `current_user` method is nothing special, and is actually covered [in the Warden guide](https://github.com/radar/guides/blob/master/warden.markdown).

So back to the code within `app/views/posts/show.html.erb`. The 'Edit Post' and 'Delete Post' links will only appear if the user is an admin. The `PostsController` itself has a similar check, in the form of a `before_action` call:

```ruby
before_action :admin_only, only: [:new, :create, :edit, :update, :destroy]

...

def admin_only
  unless admin?
    flash[:error] = "You are not authorized to do that."
    redirect_to root_path
  end
end
```

If a non-admin user attempts to access any one of the `new`, `create`, `edit`, `update` or `destroy` actions, they'll be knocked back to the root of the application with a message that tells them that they're not authorized.

All of this is well and good, but it can quickly get messy if you want to have more controllers with admin-only actions in them. Each controller would need to have its own `admin_only` method defined in it, for starters. The views can also get complicated with continuous checking for if a user is an admin. This is why moving the logic for creating, updating and destroying posts into its own unique admin-only controller is a better idea.

To start down this path, we'll create a new controller:

```
rails g controller admin/posts
```

This is the controller where we will move all the admin-only actions for posts to. The way we can do that is to extract all those actions from `PostsController` and put them into this new controller, which would be located at `app/controllers/admin/posts_controller.rb`:

```ruby
class Admin::PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :admin_only

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to admin_posts_path
      flash[:success] = 'Post was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @post.update(post_params)
      flash[:success] = 'Post was successfully updated.'
      redirect_to admin_posts_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path
    flash[:success] = 'Post was successfully deleted.'
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :text)
    end

    def admin_only
      unless admin?
        flash[:error] = "You are not authorized to perform that action."
        redirect_to root_path
      end
    end
end
```

In to this new controller, we've placed all the logic for all the post actions that admins can do. Inside the `create`, `update` and `destroy` actions, we're now redirecting back to `admin_posts_path`, which will be the page where the admin users can see all the posts. We'll define this routing helper in a moment.

This change means that our `PostsController` now only has the logic for the actions normal users can do, and that makes `PostsController` a lot cleaner:

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end
end
```

If this controller only has those two actions, that means we can limit the line in `config/routes.rb` which generates routes for this controller to only generate routes for those two actions:

```ruby
  resources :posts, only: [:index, :show] do
    resources :comments
  end
```

While we're in this file, we should define routes for our new controller, which we'll do right after the `api` namespace that already exists:

```ruby
namespace :admin do
  root :to => "posts#index"
  resources :posts
end
```

The `namespace` option here does two things: 1) it defines that all routes underneath this namespace have the `/admin` prefix and 2) all controllers are under the `Admin` module. This allows us to have a pretty clear separation in both the URL and the code about what parts of our application are for users, and what parts are for admins.

Calling `root` inside the `namespace :admin` block allows us to define a root route for this namespace. We've pointed this at the `index` action within `Admin::PostsController`. If we go into the browser now and attempt to navigate to `http://localhost:3000/admin`, we'll be told that there's no action defined:

![No index action](/admin-namespace/no-index-action.png)

Let's add this action in to `Admin::PostsController`:


```ruby
def index
  @posts = Post.all
end
```

We'll need a template for this action too, which will go at `app/views/admin/posts/index.html.erb`. We'll just display a list of posts within a table:

```erb
<h1>Listing posts</h1>

<%= link_to 'New Post', new_admin_post_path, class: 'btn btn-primary' %>

<table class='table table-striped'>
  <thead>
    <tr>
      <td>Title</td>
      <td>Actions</td>
    </tr>
  </thead>
  <tbody>
    <% @posts.each do |post| %>
      <tr>
        <td><%= post.title %></td>
        <td>
          <%= link_to 'Show', post %> &middot;
          <%= link_to 'Edit', [:edit, :admin, post] %> &middot;
          <%= link_to 'Delete', [:admin, post], method: 'delete', confirm: 'Are you sure you want to delete this post?' %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>
```

The "New Post" link uses `new_admin_post_path` now, which creates a route that routes to the `new` action within `Admin::PostsController`. The "Show" link here will infer the `post_path` helper which will go back to `PostsController`, since that's the view all the normal users will see the post as. Therefore, this is where we want to see the post too. The "Edit" and "Delete" links go to actions within the admin controller, using the `edit_admin_post_path` and `admin_post_path` helpers respectively. These helpers are defined automatically by the `namespace` code we have placed in `config/routes.rb`.

The next step is to move the views over from `app/views/posts` into `app/views/admin/posts`. We need to move the `new.html.erb` view, the `_form.html.erb` partial, and the `edit.html.erb` view. We'll also need to make changes to these views to point them to the actions within `Admin::PostsController`, rather than the old actions from within `PostsController`.

Let's change the `_form.html.erb` partial first. This line:

```erb
<%= form_for(@post) do |f| %>
```

Should turn into this:

```erb
<%= form_for([:admin, @post]) do |f| %>
```

While the form will still be displayed for the `@post` object, the route will now change to use the admin namespaced version, `admin_post_path` or `admin_posts_path` depending on if that `@post` object has been persisted or not.

In the `edit.html.erb` template, we'll need to change this:

```erb
<%= link_to 'Back', posts_path %>
```

To this:

```erb
<%= link_to 'Back', admin_posts_path %>
```

This is because we want to send admins back to the admin list of posts, rather than the normal user list of posts.

Now that we've moved the admin actions over into the namespace, we can remove the admin checks in the normal user views. The first of these is within `app/views/posts/index.html.erb`:

```erb
<% if admin? %>
  <%= link_to 'New Post', new_post_path, class: 'btn btn-primary' %>
<% end %>
```

Let's remove those lines now, since we have those within our `app/views/admin/posts/index.html.erb` template instead. The only other place we need to remove code from is `app/views/posts/show.html.erb`:

```erb
<% if admin? %>
  <%= link_to 'Edit Post', edit_post_path(@post) %> |
  <%= link_to 'Delete Post', post_path(@post), method: :delete %>
<% end %>
```

We have links for both of these links in our admin section, and so there is no need to have them here also. Let's remove that whole `if` block.

That concludes creating an admin namespace. We've moved the admin-only actions to a namespaced controller, removed admin-checking logic from the views and in general made our code easier to understand.
