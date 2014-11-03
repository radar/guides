---
layout: default
title: RubyGems Basics
url: /rubygems-basics
previous: /
next: /what-is-a-gem
---

<em class="t-gray">Use of common RubyGems commands</em>

The `gem` command allows you to interact with RubyGems.

Ruby 1.9 and newer ships with RubyGems built-in but you may need to upgrade for
bug fixes or new features.  To upgrade RubyGems or install it for the first
time (if you need to use Ruby 1.9) visit the
[download](https://rubygems.org/pages/download) page.

If you want to see how to require files from a gem, skip ahead to [What is a
gem](/what-is-a-gem)

* [Finding Gems](#finding-gems)
* [Installing Gems](#installing-gems)
* [Requiring Code](#requiring-code)
* [Listing Installed Gems](#listing-installed-gems)
* [Uninstalling Gems](#uninstalling-gems)
* [Viewing Documentation](#viewing-documentation)
* [Fetching and Unpacking Gems](#fetching-and-unpacking-gems)
* [Further Reading](#further-reading)

Finding Gems
------------

The `search` command lets you find remote gems by name.  You can use regular
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

Installing Gems
---------------

The `install` command downloads and installs the gem and any necessary
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

Here the drip command depends upon the rbtree gem which has an extension.  Ruby
installs the dependency rbtree and builds its extension, installs the drip gem,
then builds documentation for the installed gems.

You can disable documentation generation using the `--no-doc` argument when
installing gems.

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

Listing Installed Gems
----------------------

The `list` command shows your locally installed gems:

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

Uninstalling Gems
-----------------

The `uninstall` command removes the gems you have installed.

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

Viewing Documentation
---------------------

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
the `server` command:

    $ gem server
    Server started at http://0.0.0.0:8808
    Server started at http://[::]:8808

You can access this documentation at http://localhost:8808

Fetching and Unpacking Gems
---------------------------

If you wish to audit a gem's contents without installing it you can use the
`fetch` command to download the .gem file then extract its contents with the
`unpack` command.

    $ gem fetch malice
    Fetching: malice-13.gem (100%)
    Downloaded malice-13
    $ gem unpack malice-13.gem
    Fetching: malice-13.gem (100%)
    Unpacked gem: '.../malice-13'
    $ more malice-13/README

    Malice v. 13

    DESCRIPTION

    A small, malicious library.

    [...]
    $ rm -r malice-13*

You can also unpack a gem you have installed, modify a few files, then use the
modified gem in place of the installed one:

    $ gem unpack rake
    Unpacked gem: '.../rake-10.1.0'
    $ vim rake-10.1.0/lib/rake/...
    $ ruby -I rake-10.1.0/lib -S rake some_rake_task
    [...]

The `-I` argument adds your unpacked rake to the ruby `$LOAD_PATH` which
prevents RubyGems from loading the gem version (or the default version).  The
`-S` argument finds `rake` in the shell's `$PATH` so you don't have to type out
the full path.

Further Reading
---------------

This guide only shows the basics of using the `gem` command.  For information
on what's inside a gem and how to use one you've installed see the next
section, [What is a gem](/what-is-a-gem).  For a complete reference of gem
commands see the [Command Reference](/command-reference).
