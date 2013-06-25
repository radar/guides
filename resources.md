---
layout: default
title: Resources
previous: /c-extensions
next: /contributing
---

A collection of helpful material about RubyGems. Feel free to
[fork](http://github.com/rubygems/guides) and add your own!

Tutorials
---------

* [Making Ruby Gems](http://timelessrepo.com/making-ruby-gems)
* [Gem Sawyer, Modern Day Ruby Warrior](http://rubylearning.com/blog/2010/10/06/gem-sawyer-modern-day-ruby-warrior/)
* [Gemcutter & Jeweler](http://railscasts.com/episodes/183-gemcutter-jeweler)
* [MicroGems: five minute RubyGems](http://jeffkreeftmeijer.com/2011/microgems-five-minute-rubygems/) - Gems so small that you can store them in a gist.
* [Let's Write a Gem: Part 1](http://rakeroutes.com/blog/lets-write-a-gem-part-one/) and [Part 2](http://rakeroutes.com/blog/lets-write-a-gem-part-two/)
* [Polishing Rubies](http://intridea.com/blog/tag/polishing%20rubies)
* [A Practical Guide to Using Signed Ruby Gems - Part 1: Bundler](http://blog.meldium.com/home/2013/3/3/signed-rubygems-part)
* [Basic RubyGem Development](http://tech.pro/tutorial/1226/basic-rubygem-development) and [Intermediate RubyGem Development](http://tech.pro/tutorial/1277/intermediate-rubygem-development)
* [How to make a Rubygem](http://www.alexedwards.net/blog/how-to-make-a-rubygem) and [How to make a Rubygem: Part Two](http://www.alexedwards.net/blog/how-to-make-a-rubygem-part-two)

Presentations
-------------

* [History of RDoc and RubyGems](http://blog.segment7.net/2011/01/17/history-of-rdoc-and-rubygems)
* [Building a Gem](http://www.slideshare.net/sarah.allen/building-a-ruby-gem)
* [Gemology](http://www.slideshare.net/copiousfreetime/gemology)

Philosophy
----------

* [Semantic Versioning](http://semver.org/)
* [Ruby Packaging Standard](http://chneukirchen.github.com/rps/)
* [Why `require 'rubygems'` Is Wrong](http://tomayko.com/writings/require-rubygems-antipattern)
* [How to Name Gems](http://blog.segment7.net/2010/11/15/how-to-name-gems)

Patterns
--------

* [Gem Packaging: Best Practices](http://weblog.rubyonrails.org/2009/9/1/gem-packaging-best-practices)
* [Rubygems Good Practice](http://yehudakatz.com/2009/07/24/rubygems-good-practice/)
* [Gem Development Best Practices](http://blog.carbonfive.com/2011/01/22/gem-development-best-practices/)

Creating
--------

Tools to help build gems.

* [gemerator](https://github.com/rkh/gemerator) - Minimalist tool for generating skeleton gems.
* [hoe](https://github.com/seattlerb/hoe) - Rake/RubyGems helper.
* [Jeweler](https://github.com/technicalpickles/jeweler) - Opinionated tool for managing RubyGems projects.
* [micro-cutter](https://github.com/tjh/micro-cutter) - Tool to build the base files for a MicroGem.
* [newgem](https://github.com/drnic/newgem) - New gem generator.
* [RStack](https://github.com/jrun/rstack) - Generator intended for use on private gems.
* [rubygems-tasks](https://github.com/postmodern/rubygems-tasks) - Rake tasks for building, installing, and releasing Ruby Gems.
* [ore](https://github.com/ruby-ore/ore) - Project generator with a variety of templates.
* [Omnibus](https://github.com/opscode/omnibus-ruby) - Generate full-stack installers for ruby code (see this [Omnibus tutorial](http://blog.scoutapp.com/articles/2013/06/21/omnibus-tutorial-package-a-standalone-ruby-gem) for instructions on using it to package a standalone RubyGem.)

Monitoring
----------

Tools to watch gems for changes.

* [Gemnasium](https://gemnasium.com/) - Parses your GitHub projects to learn what to notify you about. Free for public repos only.
* [Gemnasium gem](https://github.com/gemnasium/gemnasium-gem) - Allows you to use Gemnasium without granting it access to private repos.
* [gemwhisperer](https://github.com/rubygems/gemwhisperer)

Hosting and Serving
-------------------

* [Geminabox](https://github.com/cwninja/geminabox)- Host your own gems, with a rubygems-compatible API.
* [Gem Mirror](https://github.com/YorickPeterse/gem-mirror) - Run an internal mirror of external gem sources.
* [Gemfury](http://www.gemfury.com/) - Private cloud-based RubyGems servers. Priced by number of collaborators.

Utilities
---------

* [gemnasium-parser](https://github.com/laserlemon/gemnasium-parser) - Determine dependencies without evaluating the ruby in gemfiles or gemspecs
* [Gemrat](https://github.com/DruRly/gemrat) - Add the latest version of a gem to your Gemfile from the command line.