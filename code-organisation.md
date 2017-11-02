# Code organisation + require in Ruby

This guide will cover:

*

## Requiring, relatively

In Ruby (and most other languages) you can choose to write your entire program
inside one big file. Normally though, Ruby programs are split across multiple
files. What we'll look at in this section is how one file can load code that is
included in a separate file. This feature is a major underpinning of how Ruby
projects are organised.

We'll start with a very simple project with just two files in it:

    .
    ├── post.rb
    └── user.rb

In `post.rb`, we might have code like this:

```ruby
class Post
  def initialize(title:)
    @title = title
  end
end
```

And in `user.rb`, we might have code like this:

```ruby
class User
  def initialize(name:)
    @name = name
  end
end
```

It's easy enough for these files at the moment to be used independently. We can
start up an IRB console and then use `require_relative` to get Ruby to load
these files and interpret the code inside of them. With the files loaded, we
can use the classes:

```
require_relative "post"
Post.new(title: "Hello world!")
require_relative "user"
User.new(name: "Ryan")
```

Requiring each file as we need it might get hard after a while, especially as
our project grows in size. What would be great would be to have one file that
required everything else for us. Let's call this file `entrypoint.rb`. It will
live in the same directory as `user.rb` and `post.rb`.

    .
    ├── entrypoint.rb
    ├── post.rb
    ├── user.rb
    └── version.rb

Inside `entrypoint.rb`, we can require both `post.rb` and `user.rb`:

```ruby
require_relative 'post'
require_relative 'user'
```

Then, in our IRB prompt, we only need to require `entrypoint.rb`:

```ruby
require_relative 'entrypoint'
```

This really cuts down on all the requiring we need to do! We can still use our
`Post` and `User` classes, as if we had required them ourselves:

```
Post.new(title: "Hello world!")
User.new(name: "Ryan")
```

Now let's say that we had another project that wanted to make use of these
classes, and this project's code lives in another directory. Here's what the
directory structure of the two projects might look like:

    ├── example
    │   ├── post.rb
    │   └── user.rb
    └── new_project
        ├── item.rb
        └── store.rb

In that `new_project/store.rb` file, we might want to make use of the `User`
class, to tie together a Store and a User, for instance. So in `store.rb`, we
could write this to load the `user.rb` file from the `example` project:

```ruby
require_relative '../example/user'
```

But then this means that `new_project` and `example` must be located in the
same directory, together. If either `new_project` or `example` gets moved, then
the whole thing falls apart. This won't do! There has to be a better way.

## Ruby project code structure

* Talk about Ruby gem structure
* Why files are namespaced

## How require works

* Talk about load path
* Talk about features
* Talk about RubyGems
* Require adds a gem's path to the load path


## Why Bundler?

* Multiple versions of gems installed
* Dependency resolution

