---
layout: default
title: Patterns
previous: /publishing
next: /specification-reference
---

Common practices to make your gem users' and other developers' lives easier.

* [Consistent naming](#consistent_naming)
* [Semantic versioning](#semantic_versioning)
* [Declaring dependencies](#declaring_dependencies)
* [Loading code](#loading_code)
* [Prerelease gems](#prerelease_gems)

Consistent naming
-----------------

> There are only two hard things in Computer Science: cache invalidation and naming things.
> -[Phil Karlton](http://martinfowler.com/bliki/TwoHardThings.html)

### File names

Be consistent with how your gem files in `lib` and `bin` are named. The
[hola](http://github.com/qrush/hola) gem from the [make your own
gem](/make-your-own-gem) guide is a great example:

    % tree
    .
    ├── Rakefile
    ├── bin
    │   └── hola
    ├── hola.gemspec
    ├── lib
    │   ├── hola
    │   │   └── translator.rb
    │   └── hola.rb
    └── test
        └── test_hola.rb

The executable and the primary file in `lib` are named the same. A developer
can easily jump in and call `require 'hola'` with no problems.

### Naming your gem

Naming your gem is important. Before you pick a name for your gem, please do a
quick search on [RubyGems.org](http://rubygems.org) or
[GitHub](http://github.com/search) to see if someone else has taken it. Every
published gem must have a unique name. There are also [some
guidelines](http://blog.segment7.net/2010/11/15/how-to-name-gems) to selecting
a good gem name, paraphrased below.

### Use underscores for spaces

This is a typical Ruby convention. For example, if a class name is
`BufferedLogger`, the file for it is usually `buffered_logger.rb`. Some
examples of gems that follow this pattern include [newrelic_rpm](http://rubygems.org/gems/newrelic_rpm)
and [factory_girl](http://rubygems.org/gems/factory_girl).

The main reason behind this is that the file name matches what your users will
`require` along with the name. For example, `gem install my_gem` will match
`require 'my_gem'`.

### Use dashes for extensions

Adding new functionality to an existing gem? Use a dash. Some examples include
[net-http-persistent](https://rubygems.org/gems/net-http-persistent) and
[autotest-growl](https://rubygems.org/gems/autotest-growl).

Usually this implies that the user will have to `require` into the
extended gem's directory tree
as well. For example, `gem install net-http-persistent` becomes `require
'net/http/persistent'`.

### Don't use UPPERCASE

Gems with uppercase names cause problems for gem users on OSX and Windows, which use
case-insensitive filesystems. Plus, when installing gems it's confusing. Do I
run `gem install Hola` or `gem install hola` ? The best practice is to use all lowercase
when naming gems.

Semantic versioning
-------------------

A versioning policy is merely a set of simple rules governing how version
numbers are allocated. It can be very simple (e.g. the version number is a
single number starting with 1 and incremented for each successive version), or
it can be really strange (Knuth’s TeX project had version numbers: 3,
3.1, 3.14, 3.141, 3.1415; each successive version added another digit to PI).

The RubyGems team urges gem developers to follow the
[Semantic Versioning](http://semver.org) standard for their gem's versions. The RubyGems
library itself does not enforce a strict versioning policy, but using an
"irrational" policy will only be a disservice to those in the community who use
your gems.

Suppose you have a 'stack' gem that holds a `Stack` class with both `push` and
`pop` functionalty. Your `CHANGELOG` might look like this if you use
semantic versioning:

* **Version 0.0.1**: The initial `Stack` class is released.
* **Version 0.0.2**: Switched to a linked list implementation because it is cooler.
* **Version 0.1.0**: Added a `depth` method.
* **Version 1.0.0**: Added `top` and made `pop` return `nil` (`pop` used to return the old top item).
* **Version 1.1.0**: `push` now returns the value pushed (it used it return `nil`).
* **Version 1.1.1**: Fixed a bug in the linked list implementation.
* **Version 1.1.2**: Fixed a bug introduced in the last fix.

Semantic versioning boils down to:

* **PATCH** `0.0.x` level changes for implementation level detail changes, such as
  small bug fixes
* **MINOR** `0.x.0` level changes for any backwards compatible API changes, such as
  new functionality/features
* **MAJOR** `x.0.0` level changes for backwards *incompatible* API changes, such
  as changes that will break existing users code if they update

Declaring dependencies
----------------------

Gems work with other gems. Here are some tips to make sure they're nice to each
other.

### Runtime vs. development

RubyGems provides two main "types" of dependencies: runtime and development.
Runtime dependencies are what your gem needs to work (such as
[rails](http://rubygems.org/gems/rails) needing
[activesupport](http://rubygems.org/gems/activesupport)).

Development dependencies are useful for when someone wants to make
modifications to your gem. When you specify development dependencies, another developer can run
`gem install --dev your_gem` and RubyGems will grab both sets of dependencies
(runtime and development). Typical development dependencies include test frameworks
and build systems

Setting dependencies in your gemspec is easy. Just use `add_runtime_dependency` and
`add_development_dependency`:

    Gem::Specification.new do |s|
      s.name = "hola"
      s.version = "2.0.0"
      s.add_runtime_dependency "daemons",
        ["= 1.1.0"]
      s.add_development_dependency "bourne",
        [">= 0"]

### Don't use `gem` from within your gem

You may have seen some code like this around to make sure you're using a
specific version of a gem:

    gem "extlib", ">= 1.0.8"
    require "extlib"

It's reasonable for applications that consume gems to use this (though they could
also use a tool like [Bundler](http://gembundler.com)). Gems themselves **should
not** do this. They should instead use dependencies in the gemspec so RubyGems
can handle loading the dependency instead of the user.

### Pessimistic version constraint

If your gem properly follows [semantic versioning](http://semver.org) with its versioning
scheme, then other Ruby developers can take advantage of this when choosing a
version constaint to lock down your gem in their app.

Let's say the following releases of a gem exist:

* **Version 2.1.0** — Baseline
* **Version 2.2.0** — Introduced some new (backward compatible) features.
* **Version 2.2.1** — Removed some bugs
* **Version 2.2.2** — Streamlined your code
* **Version 2.3.0** — More new features (but still backwards compatible).
* **Version 3.0.0** — Reworked the interface. Code written to verion 2.x might not work.

Someone who wants to use your gem has determined that version 2.2.0 works with
their software, but version 2.1.0 doesn’t have a feature they need. Adding a
dependency in a gem (or a `Gemfile` from Bundler) might look like:

    # gemspec
    spec.add_runtime_dependency 'library',
      '>= 2.2.0'

    # bundler
    gem 'library', '>= 2.2.0'

This is an "optimistic" version constraint. It's saying that all changes from
2.x on *will* work with my software, but this is usually not the case (see
version 3.0.0!)

The alternative here is to be "pessimistic". This explictly excludes the version
that might break your code.

    # gemspec
    spec.add_runtime_dependency 'library',
      ['>= 2.2.0', '< 3.0']

    # bundler
    gem 'library', '>= 2.2.0', '< 3.0'

RubyGems provides a shortcut for this, commonly known as the
[twiddle-wakka](http://robots.thoughtbot.com/post/2508037841/twiddle-wakka):

    # gemspec
    spec.add_runtime_dependency 'library',
      '~> 2.2'

    # bundler
    gem 'library', '~> 2.2'

Notice that we dropped the `PATCH` level of the version number. Had we said
`~> 2.2.0`, that would have been equivalent to `['>= 2.2.0', '< 2.3.0']`.

The important note to take home here is to be aware others *will* be using
your gems, and guard yourself from potential bugs/failures in future releases
by using `~>` instead of `>=` if at all possible.

> If you're dealing with a lot of gem dependencies in your application, we
> recommend that you take a look into [Bundler](http://gembundler.com) or
> [Isolate](http://github.com/jbarnette/isolate) which do a great job of
> managing a complex version manifest for many gems.

### Requiring RubyGems

Summary: don't.

This line...

    require 'rubygems'

...should not be necessary in your gem code, since RubyGems is loaded
already when a gem is required. Not having `require 'rubygems'` in your code
means that the gem can be easily used without needing the RubyGems client to
run.

For more information please check out [Ryan
Tomayko's](http://tomayko.com/writings/require-rubygems-antipattern) original
post about the subject.

Loading code
------------

At its core, RubyGems exists to help you manage Ruby's `$LOAD_PATH`, which is
how the `require` statement picks up new code. There's several things you can
do to make sure you're loading code the right way.

### Respect the global load path

When packaging your gem files, you need to be careful of what is in your `lib`
directory. Every gem you have installed gets its `lib` directory appended onto
your `$LOAD_PATH`. This means any file on the top level of the `lib` directory
could get required.

For example, let's say we have a `foo` gem with the following structure:

    .
    └── lib
        ├── foo
        │   └── cgi.rb
        ├── erb.rb
        ├── foo.rb
        └── set.rb

This might seem harmless since your custom `erb` and `set` files are within
your gem, but actually anyone who requires this gem will not be able to bring
in the [ERB](http://ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html) or
[Set](http://www.ruby-doc.org/stdlib/libdoc/set/rdoc/classes/Set.html) classes
provided by Ruby's stdlib.

The best way to get around this is to keep files in a different directory
under `lib`. The usual convention is to be consistent and put them in the same
folder name as your gem's name, for example `lib/foo/cgi.rb`.

### Requiring files relative to each other

Gems should not have to use `__FILE__` to bring in other Ruby files in your
gem. Code like this is surprisingly common in gems:

    require File.join(
              File.dirname(__FILE__),
              "foo", "bar")

    # or

    require File.expand_path(File.join(
              File.dirname(__FILE__),
              "foo", "bar"))

The fix is simple, just require the file relative to the load path:

    require 'foo/bar'

The [make your own gem](/make-your-own-gem) guide has a great example of this
behavior in practice, with a running test suite. The code for that gem is [on
GitHub](http://github.com/qrush/hola) as well.

### Mangling the load path

Gems should not need to change the `$LOAD_PATH` variable. RubyGems itself
manages this for you. Code like this shouldn't be necessary:

    lp = File.expand_path(File.dirname(__FILE__))
    unless $LOAD_PATH.include?(lp)
      $LOAD_PATH.unshift(lp)
    end

    # or

    __DIR__ = File.dirname(__FILE__)

    $LOAD_PATH.unshift __DIR__ unless
      $LOAD_PATH.include?(__DIR__) ||
      $LOAD_PATH.include?(File.expand_path(__DIR__))

When RubyGems activates a gem, it adds your package’s `lib` folder to the
`$LOAD_PATH` ready to be required normally by another lib or application. Its
safe to assume you can relative `require` any file in your `lib` folder.

Prerelease gems
---------------

Many gem developers have versions of their gem ready to go out for
testing or "edge" releases before a big gem release. RubyGems supports the
concept of "prerelease" versions, which could be betas, alphas,
or anything else that isn't worthy of a real gem release yet.

Taking advantage of this is easy. All you need is one or more letters in the gem version.
For example, here's what a prerelease gemspec's `version` field might look
like:

    Gem::Specification.new do |s|
      s.name = "hola"
      s.version = "1.0.0.pre"

Other prerelease version numbers might include `2.0.0.rc1`, or `1.5.0.beta.3`.
It just has to have a letter in it, and you're set. These gems can then be
installed with the `--pre` flag, like so:

    % gem list factory_girl -r --pre

    *** REMOTE GEMS ***

    factory_girl (2.0.0.beta2, 2.0.0.beta1)
    factory_girl_rails (1.1.beta1)

    % gem install factory_girl --pre
    Successfully installed factory_girl-2.0.0.beta2
    1 gem installed

Credits
-------

Several sources were used for content for this guide:

* [Rubygems Good Practice](http://yehudakatz.com/2009/07/24/rubygems-good-practice/)
* [Gem Packaging: Best Practices](http://weblog.rubyonrails.org/2009/9/1/gem-packaging-best-practices)
* [How to Name Gems](http://blog.segment7.net/2010/11/15/how-to-name-gems)
