---
layout: default
title: What is a gem?
previous: /
next: /make-your-own-gem
---

Learn what a gem can do for your Ruby applications, and what's inside of one.

* [Introduction](#introduction)
* [Structure of a Gem](#structure)
* [Requiring code](#requiring)
* [The Gemspec](#gemspec)

<a id="introduction"> </a>
Introduction
------------

A RubyGem is a software package, commonly called a "gem". Gems contain a
packaged Ruby application or library. The RubyGems software itself allows you to
easily download, install, and manipulate gems on your system.

Each gem has a name, version, and platform. For example, the
[rake](http://rubygems.org/gems/rake) gem has a `0.8.7` version. Rake's
platform is `ruby`, which means it works on any platform Ruby runs on.
Other platforms include `java` (like [nokogiri](http://rubygems.org/gems/nokogiri/versions/1.4.4.2-java))
and `mswin32` (like [sqlite-ruby](http://rubygems.org/gems/sqlite-ruby/versions/2.2.3-mswin32)).

Gems can be used to extend or modify functionality within a Ruby application.
Commonly, they're used to split out reusable functionality that others can use
in their applications as well. Some gems also provide command line utilities
to help automate tasks and speed up your work. As of Ruby 1.9.2, RubyGems is
included when you install the programming language, so gems are both
ubiquitous and extremely useful. If you're using an earlier version of Ruby, it's simple
to install RubyGems as an addon.

For information on installing or upgrading RubyGems, please visit the
RubyGems.org [download](http://rubygems.org/pages/download) page.

<a id="structure"> </a>
Structure of a Gem
------------------

Gems contain three components:

* Code (including tests and supporting utilities)
* Documentation
* gemspec

Each gem follows the same standard structure of code organization:

    % tree freewill
    freewill/
    |-- bin/
    |   `-- freewill
    |-- lib/
    |   `-- freewill.rb
    |-- test/
    |   `-- test_freewill.rb
    |-- README
    |-- Rakefile
    `-- freewill.gemspec

Here, you can see the major components of a gem:

* The `lib` directory contains the code for the gem
* The `test` or `spec` directory contains tests, depending on which test framework the developer uses
* A gem usually has a `Rakefile`, which the
[rake](http://rake.rubyforge.org/) program uses to automate tests,
generate code, and perform other tasks.
* This gem also includes an executable file in the
`bin` directory, which will be loaded into the user's your `PATH` when the gem is installed.
* Documentation is usually included in the `README` and inline with the code. When
you install a gem, documentation is generated automatically for you. Most gems
include [RDoc](http://rdoc.sourceforge.net/doc/) documentation, but some use
[YARD](http://yardoc.org/) docs instead.
* The final piece is the gemspec, which contains information about the gem. The
gem's files, test information, platform, version number and more are all laid
out here along with the author's email and name.

[More information on the gemspec file](/specification-reference/)

[Building your own gem](/make-your-own-gem/)

<a id="requiring"> </a>
Requiring code
--------------

RubyGems modifies your Ruby load path, which controls how your Ruby code is found
by the `require` statement. When you `require` a gem, really you’re just placing
that gem’s `lib` directory onto your `$LOAD_PATH`. Let’s try this out in `irb` and get
some help from the `pretty_print` library included with Ruby.

*Tip: Passing `-r` to
`irb` will automatically require a library when irb is loaded.*

    % irb -rpp
    >> pp $LOAD_PATH
    [".../lib/ruby/site_ruby/1.9.1",
     ".../lib/ruby/site_ruby",
     ".../lib/ruby/vendor_ruby/1.9.1",
     ".../lib/ruby/vendor_ruby",
     ".../lib/ruby/1.9.1",
     "."]

By default you have just a few system directories on the load path and the Ruby
standard libraries.To add the awesome_print directories to the load path, you can require its gem:

    % irb -rpp
    >> require 'ap'
    => true
    >> pp $LOAD_PATH[0]
    .../gems/awesome_print-1.0.2/lib"

Note: If you're using Ruby 1.8, you need to `require 'rubygems'` before requiring any gems. This is no longer necessary now that
RubyGems is installed with Ruby itself.

Once you’ve required rake, then RubyGems automatically drops its
`lib` directory on to the `$LOAD_PATH`. Some gems also add additional directories,
such as `bin`, to the load path. These are
completely optional and you can have many directories added to the load path by
a single gem.

That’s basically it for what’s in a gem. Drop Ruby code into `lib`, name a
Ruby file the same as your gem (so for freewill, `freewill.rb`) and it’s loaded
by RubyGems.

The `lib` directory itself normally contains only one `.rb` file,
and then another folder with the same name as the gem with more code in it. For
example:

    % tree freewill/
    freewill/
    |-- lib/
    |   |-- freewill/
    |   |   |-- core_ext/
    |   |   |   |-- array.rb
    |   |   |   `-- string.rb
    |   |   |-- user.rb
    |   |   |-- widget.rb
    |   |   `-- ...
    |   |-- freewill.rb

<a id="gemspec"> </a>
The Gemspec
-----------

Your application, your gem's users, and you 6 months from now need to know who
wrote a gem, when, and what it does. The gemspec tells you this information and
is your guide to understanding what a gem contains.

Here's an example of a gemspec file. You can learn more in [how to make a
gem](/make-your-own-gem).

    % cat freewill.gemspec
    Gem::Specification.new do |s|
      s.name        = 'freewill'
      s.version     = '1.0.0'
      s.date        = '2010-04-27'
      s.summary     = "Freewill!"
      s.description = "I will choose Freewill!"
      s.authors     = ["Nick Quaranto"]
      s.email       = 'nick@quaran.to'
      s.homepage    = 'http://example.com'
      s.files       = ["lib/freewill.rb"]
    end

For more information on the gemspec, please check out the full [Specification
Reference](/specification-reference) which goes over
each metadata field in detail.

Credits
-------

This guide was adapted from [Gonçalo Silva](https://twitter.com/#!/goncalossilva)'s
original tutorial on docs.rubygems.org and from [Gem Sawyer,
Modern Day Ruby Warrior](http://rubylearning.com/blog/2010/10/06/gem-sawyer-modern-day-ruby-warrior/).
