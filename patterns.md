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

