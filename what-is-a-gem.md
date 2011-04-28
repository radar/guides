---
layout: default
title: What is a gem?
previous: /
next: /make-your-own-gem
---

What is a gem?
==============

Learn what a gem can do for your Ruby application, and what's inside of one.

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
in their applications as well. Many gems also provide command line utilities
to help automate tasks and speed up workflows. As of Ruby 1.9.2, RubyGems is
now included when you install the programming language, so gems are both
ubiquitous and extremely useful.

For information installing RubyGems, please visit the
[Downloads](http://rubygems.org/pages/download) page.

Structure of a Gem
------------------

Gems contain three components:

* Code
* Documentation
* Gemspec

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

Here, we see the 3 major components: code, in the `lib` directory, hopefully
along with some tests as well. Tests appear in `test` or `spec`, depending on
the test framework used. A gem usually has a `Rakefile`, which the
[rake](http://rake.rubyforge.org/) program uses to help automate running tests,
generating code, and more. This gem also includes an executable file in the
`bin` directory, which will loaded onto your `PATH` once installed.

Documentation is usually included in the `README` and inline with the code. When
you install a gem, documentation is generated automatically for you. Most gems
include [RDoc](http://rdoc.sourceforge.net/doc/) documentation, but
[YARD](http://yardoc.org/) docs are also nice as well.

The final piece is the gemspec, which contains information about the gem. The
gem's files, test information, platform, version number and more are all laid
out here along with the author's email and name.

Gem structure
-------------

RubyGems manages your Ruby load path, or how your Ruby code is found
by the `require` statement. When you `require` a gem, really you’re just placing
that gem’s `lib` directory onto your `$LOAD_PATH`. Let’s try this out in `irb` and get
some help from the `pretty_print` library included with Ruby. Passing `-r` to
`irb` will automatically require a library when loaded.

    % irb -rpp
    >> pp $LOAD_PATH
    [".../lib/ruby/site_ruby/1.8",
     ".../lib/ruby/site_ruby",
     ".../lib/ruby/vendor_ruby/1.8",
     ".../lib/ruby/vendor_ruby",
     ".../lib/ruby/1.8",
     "."]

By default we have just a few system directories on our load path and the Ruby
standard libraries. If we were to run `require 'rake'` right now, it would fail,
because RubyGems isn’t loaded yet.

    % irb -rpp
    >> require 'rake'
    LoadError: no such file to load -- rake
            from (irb):2:in `require'
            from (irb):2
    >> require 'rubygems'
    => true
    >> require 'rake'
    => true
    >> pp $LOAD_PATH[0..1]
    [".../gems/rake-0.8.7/bin",
     ".../gems/rake-0.8.7/lib"]

Once we’ve required rake, then RubyGems automatically drops the `bin` and
`lib` directories onto the `$LOAD_PATH`. The `bin` directory is used for
creating executables that use your gem’s code, such as `rake`. These are
completely optional and you could have multiple per gem if you wanted.

That’s basically it for what’s in a gem. Drop Ruby code into `lib`, name a
Ruby file the same as your gem (so for freewill, `freewill.rb`) and it’s loaded
by RubyGems.

The `lib` directory normally contains only one `.rb` file on the top directory,
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

The Gemspec
-----------

Your application, your gem's users, and you 6 months from now need to know who
wrote a gem, when, and what it does. The gemspec tells you this information and
is your guide to understanding what a gem contains for you. Many developers
generate these files from build tools like [Hoe](http://seattlerb.rubyforge.org/hoe/),
[Jeweler](https://github.com/technicalpickles/jeweler), or just plain old
[Rake](http://rake.rubyforge.org/classes/Rake/GemPackageTask.html).

Here's an example of one. The next tutorial covers [how to make a
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
Reference](http://guides.rubygems.org/specification-reference) which goes over
each metadata field in detail.

Credits
-------

This guide was adapted from [Gonçalo Silva](https://twitter.com/#!/goncalossilva)'s
original tutorial on docs.rubygems.org and from [Gem Sawyer,
Modern Day Ruby Warrior](http://rubylearning.com/blog/2010/10/06/gem-sawyer-modern-day-ruby-warrior/).
