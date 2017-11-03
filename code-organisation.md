# Code organisation + require in Ruby

This guide will cover:

* How Ruby projects are organised
* How to build gems from scratch
* How `require` works to load gems installed on your system

## Requiring, relatively

In Ruby (and most other languages) you can choose to write your entire program
inside one big file. Normally though, Ruby programs are split across multiple
files. What we'll look at in this section is how one file can load code that is
included in a separate file. This feature is a major underpinning of how Ruby
projects are organised.

We'll start with a very simple project with just two files in it:

    .
    ├── response.rb
    └── user.rb

In `response.rb`, we might have code like this:

```ruby
class Response
  def initialize(submitted_at:)
    @submitted_at = submitted_at
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
start up an IRB console from within the directory that contains these files and
then use `require_relative` to get Ruby to load these files and interpret the
code inside of them. With the files loaded, we
can use the classes:

```
require_relative "response"
Response.new(submitted_at: Time.now)
require_relative "user"
User.new(name: "Ryan")
```

Requiring each file as we need it might get hard after a while, especially as
our project grows in size. What would be great would be to have one file that
required everything else for us. Let's call this file `entrypoint.rb`. It will
live in the same directory as `user.rb` and `response.rb`.

    .
    ├── entrypoint.rb
    ├── response.rb
    ├── user.rb
    └── version.rb

Inside `entrypoint.rb`, we can require both `response.rb` and `user.rb`:

```ruby
require_relative 'response'
require_relative 'user'
```

Then, in our IRB prompt, we only need to require `entrypoint.rb`:

```ruby
require_relative 'entrypoint'
```

This really cuts down on all the requiring we need to do! We can still use our
`Response` and `User` classes, as if we had required them ourselves:

```
Response.new(title: "Hello world!")
User.new(name: "Ryan")
```

Now let's say that we had another project that wanted to make use of these
classes, and this project's code lives in another directory. Here's what the
directory structure of the two projects might look like:

    ├── core
    │   ├── response.rb
    │   └── user.rb
    └── comments
        └── comment.rb

In that `comments/comment.rb` file, we might want to make use of the `User`
class, to tie together a Comment and a User, for instance. An example of this
would be code like this inside of `comment.rb`:

```ruby
class Comment
  def initialize(text, author:)
    @text = text
    @author = User.new(name: author)
  end
end
```

Ignoring the fact that the `User.new` should probably _not_ be a
responsibility of this class's initialize -- it should be done by whatever's
calling `Comment.new` -- this code indicates a strong dependency between the
`Comment` and the `User` class.

So in `comment.rb`, we
could write this to load the `user.rb` file from the `core` project:

```ruby
require_relative '../core/user'
```

But then this means that the `comments` and `core` projects must be located in the
same directory, together. If either `comments` or `core` gets moved, then
the whole thing falls apart. This won't do! There has to be a better way.

## Depending on a gem from within another gem

Indeed, there is a better way. That better way is to separate these directories
into gems, and then to very clearly define a dependency between the two gems.
This is a common approach within the Ruby community. You have probably already
a gem or two.

In the previous example, comments's code depends on features from the core
codebase, and so there should be a dependency introduced between comments and
core: comments depends on core.

Let's move our code into a gem structure now. We can generate two new gems by
running the `bundle gem` command twice:

```
bundle gem jep_core
bundle gem jep_comments
```

Let's look at the structure of the `jep_comments` gem:

```
.
├── Gemfile
├── README.md
├── Rakefile
├── bin
│   ├── console
│   └── setup
├── jep_comments.gemspec
├── lib
│   ├── jep_comments
│   │   └── version.rb
│   └── jep_comments.rb
└── spec
    ├── jep_comments_spec.rb
    └── spec_helper.rb
```

The `jep_core` gem is almost identical, but just where it would say "jep_comments"
in the above example it would say "jep_core" instead.

At the top-level of this gem, we have a file called `jep_comments.gemspec`.
This file is the _gem specification_ and this file's job is to contain data
about what your gem is named, a description of its functionality, who wrote it,
and most importantly: this gem's dependencies.

Near the bottom of this file, we can see `jep_comments` gem's dependencies listed:

```ruby
spec.add_development_dependency "bundler", "~> 1.16"
spec.add_development_dependency "rake", "~> 10.0"
spec.add_development_dependency "rspec", "~> 3.0"
```

These three lines say that when we're developing this gem, we require three
other gems to make our gem development life easy: the `bundler`, `rake` and
`rspec` gems.

The second argument to `add_development_dependency` is the required version
number of this package.  The little `~>` is [called a "twiddle-wakka" or
"tilde-wakka" and is explained here](http://guides.rubygems.org/patterns/#declaring-dependencies).

To make the jep_comments gem depend on the jep_core gem, we need to list it as a
regular dependency, which we can do with this line, underneath the development
dependencies:

```ruby
spec.add_dependency "jep_core", "~> 0.1.0"
```

By adding a dependency here, we're now stating that in order for `jep_comments` to
work at all, it needs `jep_core`. Otherwise, what's the point? The
gemspec says that `jep_comments` has a dependency on `jep_core`, and so it
_probably_ wouldn't work without `jep_core`.

For us to be able to use the `jep_comments` gem, we'll need to first install the
`jep_core` gem. Let's look at how we can install the `jep_core` gem, and then
look at how we can install the `jep_comments` gem.

## Installing the jep_core gem

Normally, we wouldn't have to manually install `jep_core`
because the `jep_core` gem would be available on RubyGems, and by installing
`jep_comments` it would automatically install `jep_core` too, because we list it
as a dependency in `jep_comments`'s gemspec.

To install the `jep_core` gem, we need to first build it, which we can do with
the `gem build` command, and the `jep_core.gemspec`. We'll need to be inside
the `jep_core` directory to run this command.

```
gem build jep_core.gemspec
```

Unfortunately, we'll see an error the first time we run this command:

```
ERROR:  While executing gem ... (Gem::InvalidSpecificationException)
    "FIXME" or "TODO" is not a description
```

This error is happening because the description of our gem inside the gemspec
is still the default description.

Before we can run `gem build` successfully, we will need to change a few lines
in our `jep_core.gemspec` file:

```ruby
spec.summary       = %q{TODO: Write a short summary, because RubyGems requires one.}
spec.description   = %q{TODO: Write a longer description or delete this line.}
```

Let's change these lines now to just the summary line:

```ruby
spec.summary       = %q{The core part for the JEP}
```

This removes the word "TODO" from the description and summary, which should
make that error go away. Let's try running `gem build` again:

```
gem build jep_core.gemspec
```

When we run this command, we'll see this output:

```
WARNING:  licenses is empty, but is recommended.  Use a license identifier from
http://spdx.org/licenses or 'Nonstandard' for a nonstandard license.
  Successfully built RubyGem
  Name: jep_core
  Version: 0.1.0
  File: jep_core-0.1.0.gem
```

The first line indicates a warning: the `gem build` command expects our gemspec
to include license information, but it doesn't. We can make this warning go
away with a small addition to our gemspec, under the summary:

```ruby
spec.license = "MIT"
```

We can run `gem build jep_core.gemspec` again to verify that this warning has
gone away.

Now to the more important part of the output of `gem build`:

```
Successfully built RubyGem
Name: jep_core
Version: 0.1.0
File: jep_core-0.1.0.gem
```

The `gem build` command has read our gemspec and has built a brand new gem for
us. This file contains all the code necessary for your gem, namely
everything but the `spec` directory. Users of the gem don't need the tests when
using this gem; only the developers of the gem need it. What's included in the
gem file is determined by the `spec.files = ...` code in the gem's gemspec.

Now that we've built the gem, we can try to install it with `gem install`:

```
gem install jep_core-0.1.0.gem
```

You might've installed a gem before by just using its name, using a command
like `gem install jep_core` or `gem install rails`. This would make RubyGems
look for that gem on rubygems.org. What we're doing here is different: we're
specifying a local file to use for our `gem install` process. The `gem install`
process will only use this local file to install our gem.

When we run this command, we'll see that it near-instantaneously installs our
gem:

```
Successfully installed jep_core-0.1.0
1 gem installed
```

It's here that I should mention that there's a shortcut for `gem build` and
`gem install`, and that is `rake install`. This will build a new gem, putting
it inside the `pkg` directory, and then install it, all in one easy step! Let's
try it now:

```
jep_core 0.1.0 built to pkg/jep_core-0.1.0.gem.
jep_core (0.1.0) installed.
```

Hooray! We've got one of our two gems installed. We'll use `rake install` in
the future instead of `gem build` and `gem install`. Now let's look at installing
the `jep_comments` gem.

## Installing the jep_comments gem

Installing the `jep_comments` gem is a matter of following the same steps that we
ran through for the `jep_core` gem:

1. Fix up the summary in `jep_comments.gemspec`
2. Add license information to `jep_comments.gemspec`.
4. Run `rake install`

When we run that `rake install` command, we'll see this:

```
jep_comments 0.1.0 built to pkg/jep_comments-0.1.0.gem.
jep_comments (0.1.0) installed.
```

Hooray on this one too! We've now got both of our gems installed. However,
these gems are both still just skeletons. We will need to move our code in from
our old projects to make them actually do something useful.

## A gem's file structure

Inside both the `jep_core` and `jep_comments` gems, there is a `lib` directory.
This directory is where the code for our gems will live. Here's what the
`jep_core/lib` directory looks like:

```
├── jep_core
│   └── version.rb
└── jep_core.rb
```

And here's what the `jep_comments/lib` directory looks like:

```
├── jep_comments
│   └── version.rb
└── jep_comment.rb
```

These are mostly the same, just the names are different. Let's take the files
from our earlier examples and put them into our gems' `lib` directory. We'll put `response.rb` and `user.rb` inside of `jep_core/lib/jep_core`, and we'll put
`comment.rb` and `item.rb` inside of `jep_comments/lib/jep_comments`.

*jep_core/lib/jep_core/response.rb*

```ruby
module JepCore
  class Response
    def initialize(submitted_at:)
      @submitted_at = submitted_at
    end
  end
end
```

*jep_core/lib/jep_core/user.rb*

```ruby
module JepCore
  class User
    def initialize(name:)
      @name = name
    end
  end
end
```

*jep_comments/lib/jep_comments/comment.rb*

```ruby
require_relative '../core/user'

module JepComment
  class Comment
    def initialize(text, author:)
      @text = text
      @author = JepCore::User.new(email: author)
    end
  end
```

There's a small thing we'll need to change in this `comment.rb` file, and
that's the `require_relative` at the top. We'll need to change it to this:

```ruby
require "jep_core/user"
```

This is because we now want to refer to the `user.rb` file from within the
`jep_core` gem. But how does Ruby know where to find this file? The answer lies
in how we've structured our gems, and how `require` works.

## Requiring files and the load path

We've put these files at `lib/jep_core` and `lib/jep_comments`, rather than
just under `lib` in both projects for a very good reason. This is so that the
files do not conflict with each other. Why would the files conflict? I'm glad
you asked!

When you're using gems in Ruby, their `lib` directories get added to a list of
directories called the _load path_. The load path is where Ruby goes looking
for files to require them. So in the case of our `jep_core` and jep_comments`
gems, both of their `lib` directories would be on the load path.

If we had a file in `jep_core/lib` that was called `user.rb` and one _also_ in
`jep_comments/lib` that was also called `user.rb`, and then in our project we
tried doing this:

```ruby
require "user"
```

How would Ruby know that we wanted the one from `jep_core` and not
`jep_comments` or vice-versa? By putting these files inside a sub-directory of
`lib`, we avoid this confusion:

```ruby
# "give me the user.rb" file from jep_core"
require "jep_core/user"
# "give me the user.rb" file from jep_comments"
require "jep_comments/user"
```

How does Ruby know where to find these files in the first place after we've
installed the gem? Well, an easy way to see this in action would be to try it
out in `irb`. We've got both of our gems installed now, so this next part
should be a cinch.

Let's open up `irb` and try working with these gems. It's not important where
you open `irb`; it will work anywhere on your machine.

We can require the `jep_core` and `jep_comments` gem like this:

```
irb(main):001:0> require 'jep_core'
true
irb(main):002:0> require 'jep_comments'
true
```

(NOTE: I have a technical explanation for how `require` finds the gem's file [on my blog](http://ryanbigg.com/2017/11/how-require-loads-a-gem))

The `true` return value here tells us that Ruby has successfully found these
files and is requiring them for the first time. If Ruby had required them
before-hand, we would see `false` here. 

But we can't use those gems' classes yet:

```
irb(main):003:0> JepCore::User.new(name: "Ryan") 
JepCore::User.new(name: "Ryan")
NameError: uninitialized constant JepCore::User
	from (irb):3
	from /Users/ryanbigg/.rubies/ruby-2.4.1/bin/irb:11:in `<main>'
```

Huh? Didn't we require the gem? Shouldn't it just _know_ about our gem's
classes? 

Yes to the first question, no to the second. Requiring a gem doesn't magically
load all that gem's classes. What that does is require the `jep_core.rb` file
at the root of our project, which just has this content in it:

```ruby
require "jep_core/version"

module JepCore
  # Your code goes here...
end
```

When we do `require 'jep_core'`, it just loads this one file. There is nothing
in our code that tells it where to find the `JepCore::User` class at the
moment, and so it is uninitialized.

This `jep_core.rb` file should be considered as the "entrypoint" to this
project. Whatever should be made available from this gem should be required
here, in this file. So at the top of this file, let's put a few more `require`
calls so that our `User` and `Response` classes are loaded:

```ruby
require "jep_core/response"
require "jep_core/user"
require "jep_core/version"

module JepCore
  # Your code goes here...
end
```

That's better! When this gem is loaded, it will now also load the
`jep_core/response.rb` and `jep_core/user.rb` files too. Going back to `irb`
and running through the same steps as before will not get us any further:

```
irb(main):001:0> require 'jep_core'
irb(main):002:0> JepCore::User.new(name: "Ryan") 
NameError: uninitialized constant JepCore::User
	from (irb):2
	from /Users/ryanbigg/.rubies/ruby-2.4.1/bin/irb:11:in `<main>'
```

This is because Ruby is still loading the old version of our gem. We will need
to install the new version of our gem to make Ruby load the new code. Let's do
this now by going into the `jep_core` gem and re-running this command:

```
rake install
```

With the gem newly rebuilt + installed, our code should now work:

```
irb(main):001:0> require 'jep_core'
=> true
irb(main):002:0> JepCore::User.new(name: "Ryan") 
=> #<JepCore::User:0x007fb3390d20c0 @name="Ryan">
```

This is a good start. We'll see the same kind of problem with our
`jep_comments` gem if we try to use a class from there:

```
irb(main):003:0> JepComments::Comment.new("A new comment!", author: "me@ryanbigg.com")
NameError: uninitialized constant JepComments::Comment
```

Let's fix this now. We'll go into the `jep_comments` gem and open up the
`lib/jep_comments.rb` file, and then we'll add a `require` for the
`jep_comments/comment.rb` file:

```ruby
require 'jep_comments/comment'
```

Because we've made changes to the `jep_comments` gem, we will need to
re-install it too. Let's run this command inside the `jep_comments` gem to do
that:

```ruby
rake install
```

We'll then go back into our `irb` prompt and try using the
`JepComments::Comment` class again:

```
irb(main):001:0> require 'jep_comments'
=> true
irb(main):002:0> JepComments::Comment.new("A new comment!", author: "me@ryanbigg.com")
=> #<JepComments::Comment:0x007ff95810b5b8 @text="A new comment!", @author=#<JepCore::User:0x007ff95810b540 @name="me@ryanbigg.com">>
```

This line creates a new instance of the `JepComments::Comment` class, which
links to a `JepCore::User` class... but we didn't require `jep_core` in `irb`
yet. What we're doing here is possible because of the `require` inside of
`jep_comments/lib/jep_comments/comment.rb`:

```ruby
require "jep_core/user"
```

This line tells Ruby that `jep_comments/lib/jep_comments/comment.rb` requires
`jep_core/user`. Ruby will dutifully load that file, and then continue with
executing the remainder of the file once `jep_core/user` has been loaded.


## Conclusion

In this guide you've seen how to share code across different projects, by
introducing dependencies between them, listing them in the gemspec and by
cross-requiring files too.
