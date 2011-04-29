---
layout: default
title: Make your own gem
previous: /what-is-a-gem
next: /patterns
---

Make your own gem
=================

From start to finish, learn how to package your Ruby code in a gem.
This guide has several parts, jump to any here:

* [Intro](#intro)
* [Your first gem](#first-gem)
* [Requiring more files](#more-files)
* [Adding an executable](#adding-an-executable)
* [Writing tests](#writing-tests)
* [Documenting your code](#documenting-code)
* [Wrapup](#wrapup)

<a id="intro"> </a>
Introduction
------------

Creating and publishing your own gem is simple thanks to the tools baked right
into RubyGems. Let’s make a simple “hello world” gem, and feel free to
play along at home! This is really as simple as it gets.

<a id="first-gem"> </a>
Your first gem
--------------

I started with just one Ruby file for my “hola” gem, and the gemspec.
You'll need a new name for yours (maybe hola_yourusername) to publish it. By
the way, there's some [basic
recommendations](http://blog.segment7.net/2010/11/15/how-to-name-gems) to follow
for naming a gem.

    % tree
    .
    +-- hola.gemspec
    `-- lib
        `-- hola.rb

Code for your package is placed within the `lib` directory. The convention is
to have *one* Ruby file with the *same* name as your gem, since that gets
loaded when `require 'hola'` is run. That one file is in charge of setting up
your gem's code and API.

The code inside of `lib/hola.rb` is pretty bare bones, we just want to see some
output.

    % cat lib/hola.rb
    class Hola
      def self.hi
        puts "Hello world!"
      end
    end

The gemspec defines what’s in the gem, who made it, and the version of the gem.
It’s also your interface to RubyGems.org, all of the information you see on a
gem page (like [jekyll](http://rubygems.org/gems/jekyll)’s) comes from the
gemspec.

    % cat hola.gemspec
    Gem::Specification.new do |s|
      s.name        = 'hola'
      s.version     = '0.0.0'
      s.date        = '2010-04-28'
      s.summary     = "Hola!"
      s.description = "A simple hello world gem"
      s.authors     = ["Nick Quaranto"]
      s.email       = 'nick@quaran.to'
      s.files       = ["lib/hola.rb"]
      s.homepage    =
        'http://rubygems.org/gems/hola'
    end

Look familiar? The gemspec is also Ruby, so you could wrap scripts to generate
the file names and bump the version number. There are lots of fields the
gemspec can contain, to see them all check out the full
[reference](/specification-reference).

Once we have our gemspec, we can build a gem from it. We can then install it
locally to test it out.

    % gem build hola.gemspec
    Successfully built RubyGem
    Name: hola
    Version: 0.0.0
    File: hola-0.0.0.gem

    % gem install ./hola-0.0.0.gem
    Successfully installed hola-0.0.0
    1 gem installed

Of course, our smoke test isn’t over yet: Let’s `require` our gem and use it!

    % irb -rubygems
    >> require 'hola'
    => true
    >> Hola.hi
    Hello world!

Hola now needs to be shared with the rest of the Ruby community. Publishing
your gem out to RubyGems.org only takes one command, granted you have an
account on the site. Once you’re signed up, then you can push out a gem.

    % gem push hola-0.0.0.gem
    Enter your RubyGems.org credentials.
    Don't have an account yet? Create one at http://rubygems.org/sign_up
       Email:   nick@quaran.to
       Password:
    Signed in.
    Pushing gem to RubyGems.org...
    Successfully registered gem: hola (0.0.0)

In just a few moments (usually a minute), your gem will be available for
installation by anyone.

    % gem list -r hola

    *** REMOTE GEMS ***

    hola (0.0.0)

    % gem install hola
    Successfully installed hola-0.0.0
    1 gem installed

It’s really that easy to share code with Ruby and RubyGems.

<a id="more-files"> </a>
Requiring more files
--------------------

Having everything in one file doesn't scale well. Let's add some more code to
this gem.

    % cat lib/hola.rb
    class Hola
      def self.hi(language = :english)
        translator = Translator.new(language)
        puts translator.hi
      end
    end

    class Hola::Translator
      def initialize(language)
        @language = language
      end

      def hi
        case @language
        when :spanish
          "hola mundo"
        else
          "hello world"
        end
      end
    end

This file is getting pretty crowded. Let's break out the `Translator` into a
separate file. As mentioned before, the gem's root file is in charge of
loading code for the gem. The other files for a gem are usually placed in a
directory of the same name of the gem inside of `lib`. We can split this gem
out like so:

    % tree
    .
    ├── hola.gemspec
    └── lib
        ├── hola
        │   └── translator.rb
        └── hola.rb

The `Translator` is now in `lib/hola`, which can easily be picked up with a
`require` statement from `lib/hola.rb`. The code for the `Translator` did not
change much:

    % cat lib/hola.rb
    class Hola::Translator
      def initialize(language)
        @language = language
      end

      def hi
        case @language
        when :spanish
          "hola mundo"
        else
          "hello world"
        end
      end
    end

But now our `hola.rb` file has some code to load the `Translator`:

    % cat lib/hola.rb
    class Hola
      def self.hi(language = :english)
        translator = Translator.new(language)
        translator.hi
      end
    end

    require 'hola/translator'

Let's try this out. First, jump into the `lib` directory, then fire up `irb`!

    % cd lib

    % irb -rhola
    irb(main):001:0> Hola.hi(:english)
    => "hello world"
    irb(main):002:0> Hola.hi(:spanish)
    => "hola mundo"

Why did we jump into `lib`? Well, by default Ruby adds the current directory
to your `$LOAD_PATH`. Since we didn't load RubyGems for that last `irb`
session, we have to rely on only Ruby's `require` to figure out where files
are. We could have appended the `lib` directory onto the `$LOAD_PATH` array,
but that's considered a bad pattern for gems. There's many more anti-patterns
(and good patterns!) for gems, explained in [this guide](/patterns).

If you've added more files to your gem, make sure to remember to add them to
your gemspec's `files` array before publishing a new gem! For this reason
alone, many developers use automation tools like
[Hoe](http://seattlerb.rubyforge.org/hoe/),
[Jeweler](https://github.com/technicalpickles/jeweler), or just plain old
[Rake](http://rake.rubyforge.org/classes/Rake/GemPackageTask.html) to generate
the gemspec.

Adding more directories with more code from here is pretty much the same
process. Split your Ruby files up when it makes sense! Making a sane order for
your project will help you and your future maintainers from headaches down the
line.

<a id="adding-an-executable"> </a>
Adding an executable
--------------------

Gems not only provide libraries of code, but they can also expose one or many
executable files to your shell's `PATH`. Probably the best known example of
this is `rake`. Another very useful one is `prettify_json.rb`, which comes
with the [JSON](http://rubygems.org/gems/json) gem, which formats JSON in a
readable manner (and is included with Ruby 1.9). Here's an example:

    % curl -s http://jsonip.com/ | \
      prettify_json.rb
    {
      "ip": "24.60.248.134"
    }

Adding executables is a simple process, you just need a file in `bin`, and set
it in the gemspec. Let's add one for the Hola gem. First let's add the file
and make it executable:

    % mkdir bin
    % touch bin/hola
    % chmod a+x bin/hola

The executable file itself just needs a
[shebang](http://www.catb.org/jargon/html/S/shebang.html) in order to figure out
what program to run it with. Here's what Hola's executable looks like:

    % cat bin/hola
    #!/usr/bin/env ruby

    require 'hola'
    puts Hola.hi(ARGV[0])

All it's doing is loading up the gem, and passing the first command line
argument as the language to say hello with. Here's an example of running it:

    % ruby -Ilib ./bin/hola
    hello world

    % ruby -Ilib ./bin/hola spanish
    hola mundo

There's another strange command line flag here: `-Ilib`. Usually RubyGems
includes the `lib` directory for us, and it will for gem executables. However,
if we're running it outside of RubyGems, we have to bring it in ourselves.

Finally, to get Hola's executable included when we push the gem, you'll need
to add it in the gemspec.

    % head -4 hola.gemspec
    Gem::Specification.new do |s|
      s.name               = 'hola'
      s.version            = '0.0.1'
      s.default_executable = 'hola'

Push up that new gem, and you'll have your own command line utility published!
You can add more executables as well in the `bin` directory if you need to,
there's an `executables` array field on the gemspec.

<a id="writing-tests"> </a>
Writing tests
--------------

Testing your gem is extremely important. Not only does it help assure you that
your code works, but it helps others know your gem does its job. When
evaluating a gem, Ruby developers tend to place a test suite (or lack thereof)
as one of the main reasons for trusting that piece of code.

Gems support adding test files into the package itself so tests can be run
when a gem is downloaded. An entire community effort has sprung up called
[GemTesters](http://test.rubygems.org/) to help document how gem test suites
run on different architectures and interpreters of Ruby.

In short: *TEST YOUR GEM!* Please!

`Test::Unit` is Ruby's built-in test framework. There are
[lots](http://www.bootspring.com/2010/09/22/minitest-rubys-test-framework/) of
[tutorials](https://github.com/seattlerb/minitest/blob/master/README.txt) for
using it online. There's many other test frameworks available for Ruby as
well, [RSpec](http://rspec.info/) is a popular choice. At the end of the day,
it doesn't matter what you use, just *TEST*!

Let's add some tests to Hola. We've got a few more files now, namely a
`Rakefile` and a brand new `test` directory.

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

Our `Rakefile` gives us some simple automation for running tests.

    % cat Rakefile
    require 'rake/testtask'

    Rake::TestTask.new do |t|
      t.libs << 'test'
    end

    desc "Run tests"
    task :default => :test

Now we can run `rake test` or simply just `rake` to run tests. Woot! Here's
what my basic test file looks like.

    % cat test/test_hola.rb
    require 'test/unit'
    require 'hola'

    class HolaTest < Test::Unit::TestCase
      def test_english_hello
        assert_equal "hello world",
          Hola.hi("english")
      end

      def test_any_hello
        assert_equal "hello world",
          Hola.hi("ruby")
      end

      def test_spanish_hello
        assert_equal "hola mundo",
          Hola.hi("spanish")
      end
    end

Finally, to run the test:

    % rake test
    (in /Users/qrush/Dev/ruby/hola)
    Loaded suite
    /Users/qrush/.rvm/gems/ruby-1.9.2-p180/gems/rake-0.8.7/lib/rake/rake_test_loader
    Started
    ...
    Finished in 0.000736 seconds.

    3 tests, 3 assertions, 0 failures, 0 errors, 0 skips

    Test run options: --seed 15331

It's green! Well, depending on your shell colors. For more great examples, the best thing you can do is hunt around
[GitHub](https://github.com/languages/Ruby) and read some code.

<a id="documenting-code"> </a>
Documenting your code
---------------------

By default most gems use [RDoc] to generate docs. There's a lot of
[great](http://handyrailstips.com/tips/12-documenting-your-application-or-plugin-using-rdoc) 
[tutorials](http://docs.seattlerb.org/rdoc/RDoc/Markup.html) for learning how
to mark up your code with RDoc. Here's a simple example:

    # The main Hola driver
    class Hola
      # Say hi to the world!
      #
      # Example:
      #   >> Hola.hi("dude")
      #   => Hello world, dude!
      #
      # Arguments:
      #   name: (String)

      def self.hi(name)
        puts "Hello world, #{name}!"
      end
    end

Another great option for documentation is [YARD](http://yardoc.org/), since
when you push a gem, [RubyDoc.info](http://rubydoc.info/) generates YARDocs
automatically from your gem. YARD is backwards compatible with RDoc, and it
has a [good
introduction](http://rubydoc.info/docs/yard/file/docs/GettingStarted.md) on
what's different and how to use it.

<a id="wrapup"> </a>
Wrapup
------

With this basic understanding of building your own RubyGem, we hope you'll be
on your way to making your own! The next few guides cover patterns in making a
gem and the other capabilities of the RubyGems system.

<a id="credits"> </a>
Credits
-------

This tutorial was adapted from [Gem Sawyer, Modern Day Ruby
Warrior](http://rubylearning.com/blog/2010/10/06/gem-sawyer-modern-day-ruby-warrior/)

The code for this gem can be found [on GitHub](https://github.com/qrush/hola).
