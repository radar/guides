RubyGems Guides
===============

An effort to provide awesome documentation for the RubyGems ecosystem.

Goals
=====

* Be the definitive place for RubyGems knowledge
* Help out those new to RubyGems get started and get things done
* Make it easy to contribute more guides

Want to help?
=============

If a guide is empty, start filling it out! Or, make a new one! Pull requests
are gladly accepted!

* Port content from docs.rubygems.org
* Port content from rubygems.org/pages/docs
* Port content from help.rubygems.org knowledge base
* Find lots of StackOverflow/ruby-talk questions and get their common answers in here
* Fill out more guides!

Setup
=====

Make sure you have jekyll installed (`gem install jekyll`), and run:

    $ jekyll --server

The pages will be available at http://localhost:4000/

Every guide except for the Command and Specification Reference is just a
straight up markdown page, so just go edit it!

For the Command Guide (`command-reference.md`), edit `command-reference.erb`
and run:

    $ rake command_guide

For the Specification Guide, the documentation comes directly from the
`Gem::Specification` class in RubyGems. Edit it, set your `RUBYGEMS_DIR` to
where your code directory is, and run:

    $ RUBYGEMS_DIR=~/Dev/ruby/rubygems rake spec_guide --trace

Thanks
======

Huge thanks to [thoughtbot](http://thoughtbot.com) whose [handbook](http://handbook.thoughtbot.com) this is based off of.

Legal
=====

The actual content of the articles is licensed under Creative Commons. The code that this project consists of is licensed under MIT.
