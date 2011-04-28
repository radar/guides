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

<pre><code>% tree
awesome/
|-- lib/
|   `-- awesome.rb
|-- test/
|   `-- test_awesome.rb
|-- README
|-- Rakefile
`-- awesome.gemspec
</code></pre>

Here, we see the 3 major components: code, in the `lib` directory, hopefully
along with some tests as well. Tests usually appear in `test` or `spec`,
depending on the test framework used. A gem usually has a `Rakefile`, which the
[rake](http://rake.rubyforge.org/) program uses to help automate running tests,
generating code, and more.

Documentation is usually included in the `README` and inline with the code. When
you install a gem, documentation is generated automatically for you. Most gems
include [RDoc](http://rdoc.sourceforge.net/doc/) documentation, but
[YARD](http://yardoc.org/) docs are also nice as well.

The final piece is the gemspec, which contains information about the gem. The
gem's author, email, name, along with the gem's files, test information,
platform, version number and more are all laid out here. The full [Specification
Reference](http://guides.rubygems.org/specification-reference) goes over each
metadata field in detail.

Loading code
-------------------

explain how code gets loaded

The Gemspec
-------------------

brief detail about a gemspec

Credits
------------------

This guide was adapted from [Gonçalo Silva](https://twitter.com/#!/goncalossilva)'s
original tutorial on docs.rubygems.org.
