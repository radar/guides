---
layout: default
title: Patterns
url: /patterns
previous: /ssl-certificate-update
next: /specification-reference
---

<em class="t-gray">Common practices to make your gem users' and other developers' lives easier.</em>

* [Consistent naming](#consistent-naming)
* [Semantic versioning](#semantic-versioning)
* [Declaring dependencies](#declaring-dependencies)
* [Loading code](#loading-code)
* [Prerelease gems](#prerelease-gems)

Consistent naming
-----------------

> There are only two hard things in Computer Science: cache invalidation and naming things.
> -[Phil Karlton](http://martinfowler.com/bliki/TwoHardThings.html)

### File names

Be consistent with how your gem files in `lib` and `bin` are named. The
[hola](https://github.com/qrush/hola) gem from the [make your own
gem](/make-your-own-gem) guide is a great example:

    % tree
    .
    ├── Rakefile
    ├── bin
    │   └── hola
    ├── hola.gemspec
    ├── lib
    │   ├── hola
    │   │   └── translator.rb
    │   └── hola.rb
    └── test
        └── test_hola.rb

The executable and the primary file in `lib` are named the same. A developer
can easily jump in and call `require 'hola'` with no problems.

### Naming your gem

Naming your gem is important.  Before you pick a name for your gem, do a
quick search on [RubyGems.org](http://rubygems.org) and
[GitHub](https://github.com/search) to see if someone else has taken it.  Every
published gem must have a unique name.  Be sure to read our [naming
recommendations](/name-your-gem) when you've found a name you like.

Semantic versioning
-------------------

A versioning policy is merely a set of simple rules governing how version
numbers are allocated. It can be very simple (e.g. the version number is a
single number starting with 1 and incremented for each successive version), or
it can be really strange (Knuth’s TeX project had version numbers: 3,
3.1, 3.14, 3.141, 3.1415; each successive version added another digit to PI).

The RubyGems team urges gem developers to follow the
[Semantic Versioning](http://semver.org) standard for their gem's versions. The
RubyGems library itself does not enforce a strict versioning policy, but using
an "irrational" policy will only be a disservice to those in the community who
use your gems.

Suppose you have a 'stack' gem that holds a `Stack` class with both `push` and
`pop` functionality. Your `CHANGELOG` might look like this if you use
semantic versioning:

* **Version 0.0.1**: The initial `Stack` class is released.
* **Version 0.0.2**: Switched to a linked list implementation because it is
  cooler.
* **Version 0.1.0**: Added a `depth` method.
* **Version 1.0.0**: Added `top` and made `pop` return `nil` (`pop` used to
  return the old top item).
* **Version 1.1.0**: `push` now returns the value pushed (it used to return
  `nil`).
* **Version 1.1.1**: Fixed a bug in the linked list implementation.
* **Version 1.1.2**: Fixed a bug introduced in the last fix.

Semantic versioning boils down to:

* **PATCH** `0.0.x` level changes for implementation level detail changes, such
  as small bug fixes
* **MINOR** `0.x.0` level changes for any backwards compatible API changes,
  such as new functionality/features
* **MAJOR** `x.0.0` level changes for backwards *incompatible* API changes,
  such as changes that will break existing users code if they update

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
modifications to your gem. When you specify development dependencies, another
developer can run `gem install --dev your_gem` and RubyGems will grab both sets
of dependencies (runtime and development). Typical development dependencies
include test frameworks and build systems.

Setting dependencies in your gemspec is easy. Just use `add_runtime_dependency`
and `add_development_dependency`:

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

It's reasonable for applications that consume gems to use this (though they
could also use a tool like [Bundler](http://bundler.io)). Gems themselves
**should not** do this. They should instead use dependencies in the gemspec so
RubyGems can handle loading the dependency instead of the user.

### Pessimistic version constraint

If your gem properly follows [semantic versioning](http://semver.org) with its
versioning scheme, then other Ruby developers can take advantage of this when
choosing a version constraint to lock down your gem in their application.

Let's say the following releases of a gem exist:

* **Version 2.1.0** — Baseline
* **Version 2.2.0** — Introduced some new (backward compatible) features.
* **Version 2.2.1** — Removed some bugs
* **Version 2.2.2** — Streamlined your code
* **Version 2.3.0** — More new features (but still backwards compatible).
* **Version 3.0.0** — Reworked the interface. Code written to version 2.x might
  not work.

You want to use a gem, and you've determined that version 2.2.0 works with
your software, but version 2.1.0 doesn't have a feature you need. Adding a
dependency in your gem (or a `Gemfile` from Bundler) might look like:

    # gemspec
    spec.add_runtime_dependency 'library',
      '>= 2.2.0'

    # bundler
    gem 'library', '>= 2.2.0'

This is an "optimistic" version constraint. It's saying that all versions greater
than or equal to 2.2.0 will work with your software.

However, you might know that 3.0 introduces a breaking change and is no longer
compatible. The way to designate this is to be "pessimistic". This explicitly
excludes the versions that might break your code:

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

If you want to allow use of newer backwards-compatible versions but need a
specific bug fix you can use a compound requirement:

    # gemspec
    spec.add_runtime_dependency 'library', '~> 2.2', '>= 2.2.1'

    # bundler
    gem 'library', '~> 2.2', '>= 2.2.1'

The important note to take home here is to be aware others *will* be using
your gems, so guard yourself from potential bugs/failures in future releases
by using `~>` instead of `>=` if at all possible.

> If you're dealing with a lot of gem dependencies in your application, we
> recommend that you take a look into [Bundler](http://bundler.io) or
> [Isolate](https://github.com/jbarnette/isolate) which do a great job of
> managing a complex version manifest for many gems.

If you want to allow prereleases and regular releases use a compound
requirement:

    # gemspec
    spec.add_runtime_dependency 'library', '>= 2.0.0.a', '< 3'

Using `~>` with prerelease versions will restrict you to prerelease versions
only.

### Requiring RubyGems

Summary: don't.

This line...

    require 'rubygems'

...should not be necessary in your gem code, since RubyGems is loaded
already when a gem is required.  Not having `require 'rubygems'` in your code
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
        │   └── cgi.rb
        ├── erb.rb
        ├── foo.rb
        └── set.rb

This might seem harmless since your custom `erb` and `set` files are within
your gem.  However, this is not harmless, anyone who requires this gem will not
be able to bring in the
[ERB](http://ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html) or
[Set](http://www.ruby-doc.org/stdlib/libdoc/set/rdoc/classes/Set.html) classes
provided by Ruby's standard library.

The best way to get around this is to keep files in a different directory
under `lib`. The usual convention is to be consistent and put them in the same
folder name as your gem's name, for example `lib/foo/cgi.rb`.

### Requiring files relative to each other

Gems should not have to use `__FILE__` to bring in other Ruby files in your
gem. Code like this is surprisingly common in gems:

    require File.join(
              File.dirname(__FILE__),
              "foo", "bar")

Or:

    require File.expand_path(File.join(
              File.dirname(__FILE__),
              "foo", "bar"))

The fix is simple, just require the file relative to the load path:

    require 'foo/bar'

Or use require_relative:

    require_relative 'foo/bar'

The [make your own gem](/make-your-own-gem) guide has a great example of this
behavior in practice, including a working test suite. The code for that gem is
[on GitHub](https://github.com/qrush/hola) as well.

### Mangling the load path

Gems should not change the `$LOAD_PATH` variable.  RubyGems manages this for
you.  Code like this should not be necessary:

    lp = File.expand_path(File.dirname(__FILE__))
    unless $LOAD_PATH.include?(lp)
      $LOAD_PATH.unshift(lp)
    end

Or:

    __DIR__ = File.dirname(__FILE__)

    $LOAD_PATH.unshift __DIR__ unless
      $LOAD_PATH.include?(__DIR__) ||
      $LOAD_PATH.include?(File.expand_path(__DIR__))

When RubyGems activates a gem, it adds your package's `lib` folder to the
`$LOAD_PATH` ready to be required normally by another lib or application.  It
is safe to assume you can then `require` any file in your `lib` folder.

Prerelease gems
---------------

Many gem developers have versions of their gem ready to go out for testing or
"edge" releases before a big gem release. RubyGems supports the concept of
"prerelease" versions, which could be betas, alphas, or anything else that
isn't ready as a regular release.

Taking advantage of this is easy. All you need is one or more letters in the
gem version.  For example, here's what a prerelease gemspec's `version` field
might look like:

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
