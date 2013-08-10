---
layout: default
title: What is a gem?
previous: /
next: /make-your-own-gem
---

Learn what a gem can do for your Ruby applications, and what's inside of one.

* [Introduction](#introduction)
* [Finding Gems](#finding)
* [Installing Gems](#installing)
* [Structure of a Gem](#structure)
* [Requiring code](#requiring)
* [The Gemspec](#gemspec)

<a id="introduction"> </a>
Introduction
------------

A gem is a ruby software package that contains a packaged Ruby application or
library.  The RubyGems software itself allows you to easily download, install,
and manipulate gems on your system.

A gem is installed by the RubyGems software.  Ruby 1.9 ships with RubyGems
built-in but you may need to upgrade for bug fixes or new features.  To upgrade
RubyGems or install it for the first time (if you need to use Ruby 1.9) visit
the [download](https://rubygems.org/pages/download) page.

Gems can be used to extend or modify functionality within a Ruby application.
Commonly they're used to split out reusable functionality that others can use
in their applications or libraries.  Some gems also provide command line
utilities to help automate tasks and speed up your work.

<a id="finding"> </a>
Finding Gems
------------

The search command lets you find remote gems by name.  You can use regular
expression characters in your query:

    $ gem search ^rails

    *** REMOTE GEMS ***

    rails (4.0.0)
    rails-3-settings (0.1.1)
    rails-action-args (0.1.1)
    rails-admin (0.0.0)
    rails-ajax (0.2.0.20130731)
    [...]

If you see a gem you want more information on you can add the details option.
You'll want to do this with a small number of gems, though, as listing gems
with details requires downloading more files:

    $ gem search ^rails$ -d

    *** REMOTE GEMS ***

    rails (4.0.0)
        Author: David Heinemeier Hansson
        Homepage: http://www.rubyonrails.org

        Full-stack web application framework.

You can also search for gems on rubygems.org such as [this search for
rake](https://rubygems.org/search?utf8=✓&query=rake)

<a id="installing"> </a>
Installing Gems
---------------

The install command downloads and installs the gem and any necessary
dependencies then builds documentation for the installed gems.

    $ gem install drip
    Fetching: rbtree-0.4.1.gem (100%)
    Building native extensions.  This could take a while...
    Successfully installed rbtree-0.4.1
    Fetching: drip-0.0.2.gem (100%)
    Successfully installed drip-0.0.2
    Parsing documentation for rbtree-0.4.1
    Installing ri documentation for rbtree-0.4.1
    Parsing documentation for drip-0.0.2
    Installing ri documentation for drip-0.0.2
    Done installing documentation for rbtree, drip after 0 seconds
    2 gems installed

You can list your locally installed gems:

    $ gem list

    *** LOCAL GEMS ***

    bigdecimal (1.2.0)
    drip (0.0.2)
    io-console (0.4.2)
    json (1.7.7)
    minitest (4.3.2)
    psych (2.0.0)
    rake (0.9.6)
    rbtree (0.4.1)
    rdoc (4.0.0)
    test-unit (2.0.0.0)

(Ruby ships with some gems by default, bigdecimal, io-console, json, minitest,
psych, rake, rdoc, test-unit for ruby 2.0.0).

You can view the documentation for your installed gems with `ri`:

    $ ri RBTree
    RBTree < MultiRBTree

    (from gem rbtree-0.4.0)
    -------------------------------------------
    A sorted associative collection that cannot
    contain duplicate keys. RBTree is a
    subclass of MultiRBTree.
    -------------------------------------------

You can view the documentation for your installed gems in your browser with
the server command:

    $ gem server
    Server started at http://0.0.0.0:8808
    Server started at http://[::]:8808

You can access the documentation at `http://localhost:8808`

You can uninstall gems with the uninstall command.

    $ gem uninstall drip
    Successfully uninstalled drip-0.0.2

If you uninstall a dependency of a gem RubyGems will ask you for confirmation.

    $ gem uninstall rbtree

    You have requested to uninstall the gem:
    	rbtree-0.4.1

    drip-0.0.2 depends on rbtree (>= 0)
    If you remove this gem, these dependencies will not be met.
    Continue with Uninstall? [yN]  n
    ERROR:  While executing gem ... (Gem::DependencyRemovalException)
        Uninstallation aborted due to dependent gem(s)

<a id="structure"> </a>
Structure of a Gem
------------------

Each gem has a name, version, and platform. For example, the
[rake](http://rubygems.org/gems/rake) gem has a `0.8.7` version (from May,
2009).  Rake's platform is `ruby`, which means it works on any platform Ruby
runs on.

Platforms are based on the CPU architecture, operating system type and
sometimes the operating system version.  Examples include "x86-mingw32" or
"java".  The platform indicates the gem only works with a ruby built for the
same platform.  RubyGems will automatically download the correct version for
your platform.  See `gem help platform` for full details.

Inside a gems are the following components:

* Code (including tests and supporting utilities)
* Documentation
* gemspec

Each gem follows the same standard structure of code organization:

    % tree freewill
    freewill/
    ├── bin/
    │   └── freewill
    ├── lib/
    │   └── freewill.rb
    ├── test/
    │   └── test_freewill.rb
    ├── README
    ├── Rakefile
    └── freewill.gemspec

Here, you can see the major components of a gem:

* The `lib` directory contains the code for the gem
* The `test` or `spec` directory contains tests, depending on which test
  framework the developer uses
* A gem usually has a `Rakefile`, which the
  [rake](http://rake.rubyforge.org/) program uses to automate tests,
  generate code, and perform other tasks.
* This gem also includes an executable file in the
  `bin` directory, which will be loaded into the user's `PATH` when the gem is
  installed.
* Documentation is usually included in the `README` and inline with the code.
  When you install a gem, documentation is generated automatically for you.
  Most gems include [RDoc](http://rdoc.sourceforge.net/doc/) documentation,
  but some use [YARD](http://yardoc.org/) docs instead.
* The final piece is the gemspec, which contains information about the gem.
  The gem's files, test information, platform, version number and more are all
  laid out here along with the author's email and name.

[More information on the gemspec file](/specification-reference/)

[Building your own gem](/make-your-own-gem/)

<a id="requiring"> </a>
Requiring code
--------------

RubyGems modifies your Ruby load path, which controls how your Ruby code is
found by the `require` statement. When you `require` a gem, really you're just
placing that gem's `lib` directory onto your `$LOAD_PATH`. Let's try this out
in `irb` and get some help from the `pretty_print` library included with Ruby.

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
standard libraries.  To add the awesome_print directories to the load path,
you can require one of its files:

    % irb -rpp
    >> require 'ap'
    => true
    >> pp $LOAD_PATH.first
    ".../gems/awesome_print-1.0.2/lib"

Note:  For Ruby 1.8 you must `require 'rubygems'` before requiring any gems.

Once you've required `ap`, RubyGems automatically places its
`lib` directory on the `$LOAD_PATH`.

That's basically it for what's in a gem.  Drop Ruby code into `lib`, name a
Ruby file the same as your gem (for the gem "freewill" the file should be
`freewill.rb`, see also [name your gem](/name-your-gem)) and it's loadable by
RubyGems.

The `lib` directory itself normally contains only one `.rb` file and a
directory with the same name as the gem which contains the rest of the files.

For example:

    % tree freewill/
    freewill/
    └── lib/
        ├── freewill/
        │   ├── user.rb
        │   ├── widget.rb
        │   └── ...
        └── freewill.rb

<a id="gemspec"> </a>
The Gemspec
-----------

Your application, your gem's users, and you 6 months from now will want to
know who wrote a gem, when, and what it does.  The gemspec contains this
information.

Here's an example of a gemspec file. You can learn more in [how to make a
gem](/make-your-own-gem).

    % cat freewill.gemspec
    Gem::Specification.new do |s|
      s.name        = 'freewill'
      s.version     = '1.0.0'
      s.summary     = "Freewill!"
      s.description = "I will choose Freewill!"
      s.authors     = ["Nick Quaranto"]
      s.email       = 'nick@quaran.to'
      s.homepage    = 'http://example.com/freewill'
      s.files       = ["lib/freewill.rb", ...]
    end

For more information on the gemspec, please check out the full [Specification
Reference](/specification-reference) which goes over each metadata field in
detail.

Credits
-------

This guide was adapted from [Gonçalo
Silva](https://twitter.com/#!/goncalossilva)'s original tutorial on
docs.rubygems.org and from [Gem Sawyer, Modern Day Ruby
Warrior](http://rubylearning.com/blog/2010/10/06/gem-sawyer-modern-day-ruby-warrior/).
