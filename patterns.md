---
layout: default
title: Patterns
previous: /make-your-own-gem
next: /command-reference
---

Patterns
========

Common practices to make your gem users and other developers' lives easier.

* [Consistent naming](#consistent-naming)
* [Semantic versioning](#semantic-versioning)
* [Declaring dependencies](#declaring-dependencies)
* [Loading code](#loading-code)
* [Other files](#other-files)
* [Requiring 'rubygems'](#requiring-rubygems)
* [Prerelease gems](#prerelease-gems)

<a id="consistent-naming"> </a>
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
[GitHub](http://github.com/search) to see if someone else has taken it. Once
you have a name, we have a [few
guidelines](http://blog.segment7.net/2010/11/15/how-to-name-gems) on how
to name them, paraphrased below.

### Use underscores for spaces

Such as [newrelic_rpm](http://rubygems.org/gems/newrelic_rpm) or
[factory_girl](http://rubygems.org/gems/factory_girl). This matches the file in
your gem that your users will `require` along with the name. For example,
`gem install my_gem` will match `require 'my_gem'`

### Use dashes for extensions

Adding new functionality to an existing gem? Use a dash. Some examples include
[net-http-persistent](https://rubygems.org/gems/net-http-persistent) and
[autotest-growl](https://rubygems.org/gems/net-http-persistent).

Usually this implies that you'll have to `require` into their directory tree
as well. For example, `gem install net-http-persistent` becomes `require
'net/http/persistent'`.

### Don't use UPPERCASE

These gems cause problems for gem users on OSX and Windows, which use
case-insensitive filesystems. Plus, when installing gems it's confusing. Do I
run `gem install Hola` or `gem install hola` ? Just keep it lowercase.

<a id="semantic-versioning"> </a>
Semantic versioning
-------------------

A versioning policy is merely a set of simple rules governing how version
numbers are allocated. It can be very simple (e.g. the version number is a
single number starting with 1 and incremented for each successive version), or
it can be really strange (Knuth’s[#knuth] TeX project had version numbers: 3,
3.1, 3.14, 3.141, 3.1415; each successive version added another digit to PI).

The RubyGems team **strongly recommends** gem developers to follow [Semantic
Versioning](http://semver.org) for their gem's versions. The RubyGems library itself does
not enforce a strict versioning policy, but using an "irrational" policy will
only be a disservice to those in the community who use your gems.

Let's say we have a 'stack' gem that holds a `Stack` class with both `push` and
`pop` functionalty. Our `CHANGELOG` with SemVer version bumping might look
like this:

* **Version 0.0.1**: The initial Stack class is release.
* **Version 0.0.2**: Switched to a linked list implementation because it is cooler.
* **Version 0.1.0**: Added a `depth` method.
* **Version 1.0.0**: Added `top` and made `pop` return nil (pop used to return the old top item).
* **Version 1.1.0**: `push` now returns the value pushed (it used it return nil).
* **Version 1.1.1**: Fixed a bug in the linked list implementation.
* **Version 1.1.2**: Fixed a bug introduced in the last fix.

This system can basically boil down to:

* **PATCH** `0.0.x` level changes for implementation level detail changes, such as
  small bug fixes
* **MINOR** `0.x.0` level changes for any backwards compatible API changes, such as
  new functionality/features
* **MAJOR** `x.0.0` level changes for backwards *incompatible* API changes, such
  as changes that will break existing users code if they update

If you're dealing with a lot of gem dependencies in your application, we
recommend that you take a look into [Bundler](http://gembundler.com) or
[Isolate](http://github.com/jbarnette/isolate) which do a great job of
managing a complex version manifest for many gems.

<a id="declaring-dependencies"> </a>
Declaring dependencies
----------------------

Gems work with other gems. Here's some tips to make sure they're nice to each
other.

### Runtime vs. development

RubyGems provides two main "types" of dependencies: runtime and development.
Runtime dependencies are what your gem needs to work (such as
[rails](http://rubygems.org/gems/rails) needing
[activesupport](http://rubygems.org/gems/activesupport)).

Development dependencies are useful for when someone wants to make
modifications to your gem. Once specified, someone can run
`gem install --dev your_gem` and RubyGems will grab both sets of dependencies
necessary. Usually development dependencies include test frameworks, build
systems, etc.

Setting them in your gemspec is easy, just use `add_runtime_dependency` and
`add_development_dependency`:

    Gem::Specification.new do |s|
      s.name = "hola"
      s.version = "2.0.0"
      s.add_runtime_dependency("daemons", ["= 1.1.0"])
      s.add_development_dependency("bourne", [">= 0"])


### Don't use `gem` from within your gem

You may have seen some code like this around to make sure you're using a
specific version of a gem:

    gem "extlib", ">= 1.0.8"
    require "extlib"

It's reasonable for appliations that consume gems to use this (but they could
also use a tool like [Bundler](http://gembundler.com)). Gems themselves **should
not** do this, they should instead use dependencies in the gemspec so RubyGems
can handle loading the dependency instead of the user.

### The twiddle-wakka

Explain ~>.

### `require 'rubygems'`

<a id="loading-code"> </a>
Loading code
------------

<a id="other-files"> </a>
Other files
-----------

<a id="prerelease-gems"> </a>
Prerelease gems
---------------


Credits
-------

Several sources were used for content for this guide:

* [Rubygems Good Practice](http://yehudakatz.com/2009/07/24/rubygems-good-practice/)
* [Gem Packaging: Best Practices](http://weblog.rubyonrails.org/2009/9/1/gem-packaging-best-practices)
* [How to Name Gems](http://blog.segment7.net/2010/11/15/how-to-name-gems)
