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

<a id="loading-code"> </a>
Loading code
------------

<a id="other-files"> </a>
Other files
-----------

<a id="requiring-rubygems"> </a>
Requiring `'rubygems'`
--------------------

<a id="prerelease-gems"> </a>
Prerelease gems
--------------------

