# Developing a RubyGem using Bundler

Bundler is a tool created by Carl Lerche, Yehuda Katz, André Arko and various superb contributors for managing Rubygems dependencies in Ruby libraries. Bundler 1.0 was released around the same time as Rails 3 and it's the Rails project where Bundler is probably most well-known usage occurs. But remember, Bundler isn't just for Rails!

Did you know that you can use Bundler for not only gem dependency management but also for writing our own gems? It's really easy to do this and Bundler provides a couple of things to help you along this path. 

## But first, why?

Why should we create a gem? Can't we just throw in some code into our *other* library and use that instead? Sure, we can do that. But then what if we want to use the code elsewhere, or we want to share it? This is why a gem is perfect. We can code our library and a gem separately from each other and just have the library require the gem. If we want to use the gem in another library, then it's just a tiny modification rather than a whole slew of copying.

Also: Sharing is caring.

## Getting Started

To begin to create a gem using Bundler, use the `bundle gem` command like this:

    bundle gem gem_name
    
We call our gem `gem_name` because we're not very imaginative with gem names and the chance that somebody else has named their gem this is pretty low.
    
This command creates a scaffold directory for our new gem and if we have Git installed initializes a Git repository in this directory so we can start committing right away. The files generated are:

 * **Gemfile**: Used to manage gem dependencies for our library's development. This file contains a `gemspec` line meaning that Bundler will include dependencies specified in _gem\_name.gemspec_ too. It's best practice to specify the gems that our library depends on for "production" usage in the _gemspec_, and the gems for development of the library in the _Gemfile_.
 
 * **Rakefile**: Requires Bundler and adds the `build`, `install` and `release` Rake tasks by way of calling _Bundler::GemHelper.install\_tasks_. The `build` task will build the current version of the gem and store it under the _pkg_ folder, the `install` task will build _and_ install the gem to our system (just like it would do if we `gem install`'d it) and `release` will push the gem to Rubygems for consumption by the public.
 
 * **.gitignore**: (only if we have Git). This ignores anything in the _pkg_ directory (generally files put there by `rake build`), anything with a _.gem_ extension and the _.bundle_ directory.
 
 * **gem\_name.gemspec**: The Gem Specification file. This is where we provide information for Rubygems' consumption such as the name, description and homepage of our gem. This is also where we specify the dependencies our gem needs to run. Remember: "production" dependencies in the gemspec, development dependencies in the _Gemfile_
 
 * **lib/gem\_name.rb**: The main file to define our gem's code. This is the file that will be required by Bundler (or any similarly smart system) when our gem is loaded. This file defines a `module` which we can use a namespace for all our gem's code. It's best practice to put our code in...
 
 * **lib/gem\_name**: here. This folder should contain all the code (classes, etc.) for our gem. The _lib/gem\_name.rb_ file is there for setting up our gem's environment, whilst all the parts to it go in this folder. If our gem has multiple uses, separating this out so that people can require one class/file at a time can be really helpful.
 
 * **lib/gem\_name/version.rb**: Defines a `GemName` constant and in it, a `VERSION` constant. This file is loaded by the _gem\_name.gemspec_ to specify a version for the gem specification. When we release a new version of the gem we will increment a part of this version number to indicate to Rubygems that we're releasing a new version.
 
There's our base and our layout, now get developing!

## Testing our gem

For this guide, we're going to use RSpec to test our gem. We write tests to ensure that everything goes according to plan and to prevent future-us from building a time machine to come back and kick our asses. 

To get started with writing our tests, we'll create a _spec_ directory at the root of gem by using the command `mkdir spec`. Next, we'll specify in our _Gemfile_ that we need to use `rspec` to test our gem. We will put these lines in:

    group :test do
      gem 'rspec', '2.0.0.beta.22'
    end

When we run `bundle install`, rspec will be installed for this library and any other library we use with Bundler, but not for the system. This is an important distinction to make: any gem installed by Bundler will not muck about with gems installed by `gem install`. It is effectively a sandboxed environment. It is best practice to use Bundler to manage our gems so that we do not have gem version conflicts.

Additionally in the `bundle install` output, we will see this line:

    Using gem_name (0.0.1) from source at /path/to/gem_name
    
Bundler has detected our gem and has loaded the gemspec and our gem is bundled just like every other gem.

To run the `rspec` command for our bundle, we must use `bundle exec rspec`. This will use the bundled version of rspec rather than the system version. We can run it now by running `bundle exec rspec spec` to test precisely nothing. At least it works, right?

We can write our first test with this framework now in place. For testing, we create a new RSpec file for every class we want to test at the root of the _spec_ directory. If we had multiple facets to our gem, we would group them underneath a directory such as _spec/facet_ but this is a simple gem, so we won't. Let's call this new file _spec/food_spec.rb_ and fill it with this content:

    describe GemName::Food do
      it "broccoli is gross" do
        GemName::Food.portray("Broccoli").should eql("Gross!")
      end
      
      it "anything else is delicious" do
        GemName::Food.portray("Not Broccoli").should eql("Delicious!")
      end
    end

When we run `bundle exec rspec spec` again, we'll be told the `GemName::Food` constant doesn't exist. This is true, and we should define it in _lib/gem_name/food.rb_ like this:

    module GemName
      class Food
        def self.portray(food)
          if food.downcase == "broccoli"
            "Gross!"
          else
            "Delicious"
          end
        end
      end
    end

We can then require this file at the top of our spec file by using this line:

    require 'gem_name/food'
    
When we run our specs with `bundle exec rspec spec` this test will pass:

    .
    1 example, 0 failures

Great success! If we're using Git (or any other source control system), this is a great checkpoint to commit our code. Always remember to commit often!

It's all well and dandy that we can write our own code, but what if we want to depend on another gem? That's easy too.

## Using other gems

We're now going to use Active Support's `pluralize` method by calling it using a method from our gem.

To use another gem, we must first specify it as a dependency in our _gem\_name.gemspec_. We can specify the dependency on the `activesupport` gem in _gem\_name.gemspec_ by adding this line inside the `Gem::Specification` object:

    s.add_dependency "activesupport", "3.0.0"
    
If we wanted to specify a particular version we may use this line:

    s.add_dependency "activesupport", ">= 2.3.8"
    
However, relying on a version simply greater than the latest-at-the-time is a sure-fire way to run into problems later on down the line. Try to always use `~>` for specifying dependencies.

When we run `bundle install` again, the `activesupport` gem will be installed for us to use. Of course, like the diligent TDD/BDD zealots we are, we will test our `group` method before we code it. Let's add this test to _spec/food\_spec.rb_ now inside our `describe GemName::Food` block:

    it "pluralizes a word" do
      GemName::Food.pluralize("Tomato").should eql("Tomatoes")
    end

Of course when we run this spec with `bundle exec rspec spec` it will fail:

    Failure/Error: GemName::Food.pluralize("Tomato").should eql("Tomatoes")
         undefined method `pluralize' for GemName::Food:Class

We can now define this `pluralize` method in _lib/gem\_name/food.rb_ by first off requiring the part of Active Support which contains the `pluralize` method. This line should go at the top of the file, just like all good `require`s do.

    require 'active_support/inflector'
    
Next, we can define the `pluralize` method like this:

    def self.pluralize(word)
      word.pluralize
    end

When we run `bundle exec rspec spec` both our specs will pass:

    ...
    3 examples, 0 failures
    
This brings another checkpoint where it'd be a good idea to commit our efforts so far.

It's great that we're able to call our gem's methods now (all two of them!) and get them to return strings, but everybody knows that the best gems come with command line interfaces (hereafter, "CLI"). You can tell right now just how uncool this gem is because it doesn't have a CLI, right? It needs one. It craves one.

It deserves one.

## Testing a command line interface

Before we go jumping headlong into giving our gem the best darn CLI a gem-with-only-two-methods-that-both-return-useless-strings it can have, let's consider how we're going to test this first. We're zealots, remember? Now if only there was a tool we could use. It would have to have a cool name, of course.

Like "Aruba". (BAM)[http://github.com/aslakhellesoy/aruba].

David Chelimsky and Aslak Hellesøy teamed up to create Aruba, a CLI testing tool, which they both use for RSpec and Cucumber, and now we too can use it for testing our gems. Oh hey, speaking of Cucumber that's also what we're going to be using to define the Aruba tests. Human-code-client-readable tests are the way of the future, man.

We will define a new `group` in our _Gemfile_ now for the Cucumber things:

    group :cucumber do
      gem 'cucumber'
      gem 'aruba'
    end

Hot. Let's run `bundle install` to get these awesome tools set up.

Our CLI is going to have two methods, which correspond to the two methods which we have defined in `GemName::Food`. We will now create a _features_ directory where we will make sweet, sweet love to Aruba to write tests for our CLI. In this directory we'll create a new file called _features/food.feature_ and in it, fill it with this juicy code:

    Feature: Food
      In order to portray or pluralize food
      As a CLI
      I want to be as objective as possible
  
      Scenario: Broccoli is gross
        When I run "gem_name portray broccoli"
        Then the output should contain "Gross!"

      Scenario: Tomato, or Tomato?
        When I run "gem_name pluralize --word Tomato"
        Then the output should contain "Tomatoes"
        
These scenarios test the CLI our gem will provide. In the `When I run` steps, the first word inside the quotes is the name of our executable, the second is the task name, and any further text is arguments or options. Yes, it *is* testing what appears to be the same thing as our specs. How very observant of you. Gold star! But it's testing it through a CLI, which makes it *supremely awesome*. Contrived examples are _in_ this year.

The first scenario ensures that we can call a specific task and pass it a single argument which then becomes the part of the text that is output. The second scenario ensures effectively the same thing, but we pass that value in as an option rather than an argument.     

To run this feature, we use the `cucumber` command, but of course because it's available within the context of our bundle, we use `bundle exec cucumber` like this:

    bundle exec cucumber features/
    
See those yellow things? They're undefined steps:

    When /^I run "([^"]*)"$/ do |arg1|
      pending # express the regexp above with the code you wish you had
    end

    Then /^the output should contain "([^"]*)"$/ do |arg1|
      pending # express the regexp above with the code you wish you had
    end
    
We can define them by requiring Aruba. In Cucumber, all _.rb_ files in the _features/support_ directory are required. To prove this to ourselves, we can add a _features/support/setup.rb_ file (create the _support_ directory first) and put in this single line:

    require 'aruba'
   
This loads Aruba which will define the steps our Cucumber features need to be awesome.
   
We have to re-run `bundle exec cucumber features`, just to see what happens next. We see red. Red like the blood incessantly seeping from the walls. It contains this cryptic message:

    sh: gem_name: command not found
   
OK, so it's not *that* cryptic. It just means it can't find the executable file for our gem. No worries, we can create one in the _bin_ directory and name it _gem\_name_. This file has no extension because it's an *executable* file rather than a script. We don't want to go around calling `gem_name.rb` everywhere, do we? No, no we don't. We will fill this file with this content:

    #!/usr/bin/env ruby
    print "nothing."
    
If this file was completely empty, we would run into a non-friendly `Errno::ENOEXEC` error.

Alright so we've got the executable file, now what? If we re-run our features we get *nothing* for the output. Nothing! Literally!

    got: "nothing."
    
     
Our _bin/gem\_name_ file is empty, which results in this Nothing Travesty. Get rid of the `print "nothing"` line and replace it with all the code required to run our CLI, which consists of two lines:

    require 'gem_name/cli'
    GemName::CLI.start
    

Boom! When we run `bundle exec cucumber features` again it will whinge that there's no _gem\_name/cli_ file to require. Before we go into what this file does, we should explain the code on the _other_ line of the _bin/gem\_name_ file. The `start` method fires up our `CLI` class and will look for a task that matches the one we ask for.

 Ok, so it's therefore obvious that the next step is to create this file, but what does it do? 

This new _gem\_name/cli.rb_ file will define the command line interface using another gem called `Thor`. Thor was created by Yehuda Katz (& collaborators) as an alternative to the Rake build tool. Thor provides us with a handy API for defining our CLI, including usage banners and help output. The syntax is very similar to Rake. Additionally, Rails and Bundler both use Thor for their CLI interface as well as their generator base. Yes, Thor even does generators!

For now we'll just look at how we can craft a CLI using Thor and then afterwards, if you behave, we'll look at how to write a generation using it too.

## Crafting a CLI

Let's define the _gem\_name/cli.rb_ file now like this:

    module GemName
      class CLI < Thor
    
      end
    end
    
The `Thor` class has a series of methods that we can use to define CLI methods in our class. Our class doesn't have to be called `CLI`, it's just best practice to do so. We don't magically get this `Thor` class; we need to tell our _gemspec_ that we depend on this gem by adding this line underneath our previous _add\_dependency_:


    s.add_dependency "thor"
    
We also need to require it at the top of _gem\_name/cli.rb_

    require 'thor'
    
To install this new dependency, we use `bundle install`. When we run `bundle exec cucumber features` again, we'll see that it's now complaining that it could not find the tasks we're calling:

    Could not find task "portray"
    ...
    Could not find task "group"
    
Thor tasks are defined as plain ol' methods, but with a slight twist. To define the `portray` task in our `GemName::CLI` class we will write this inside the `GemName::CLI` class:

    desc "portray ITEM", "Determines if a piece of food is gross or delicious"
    def portray(name)
      puts GemName::Food.portray(name)
    end
    
The `desc` method is the "slight twist" here. The method defined after it becomes a task with the given description. The first argument for `desc` is the usage instructions for the task whilst the second is the short description of what that task accomplishes. The `portray` method is defined with a single argument, which will be the first argument passed to this task on the command line. Inside the `portray` method we call `GemName::Food.portray` and pass it this argument.

In the `GemName::CLI` class we're referencing the `GemName::Food` class without requiring the file that defines it. Under the `require 'thor'` at the top of this file, put this line to require the file that defines `GemName::Food`:

    require 'gem_name/food'
    
When we re-run our features using `bundle exec cucumber features` our first scenario will pass:

    2 scenarios (1 failed, 1 passed)
    4 steps (1 failed, 3 passed)

The second and third are still failing because we haven't defined the `group` task for them. This time rather than defining a task that takes an argument, we'll define a task that reads in the value from an option passed to the task. To define the `group` task we use this code in `GemName::CLI`:


    desc "pluralize", "Pluralizes a word"
    method_option :word => :string, :aliases => "-w"
    def pluralize
      puts GemName::Food.pluralize(options[:word])
    end

Here there's the new `method_option` method we use which defines, well, a method option. It takes a hash which indicates the details of an option how they should be returned to our task. Check out the Thor README for a full list of valid types. We can also define aliases for this method using the `:aliases` option passed to `method_option`. Inside the task we reference the value of the options through the `options` hash and we use `GemName::Food.pluralize` to pluralize a word.

When we run our scenarios again with `bundle exec cucumber features` both scenarios will be passing:

    2 scenarios (2 passed)
    4 steps (4 passed)

This introduction should have whet your appetite to learn more about Thor and it's encouraged that you do that now. Check out `Bundler::CLI` for a great example of using Thor as a CLI tool.

With our features and specs all passing now, we're at a good point to commit our code. 

It was aforementioned that we could use Thor for more than just CLI. That we could use it to create a generator. This is true. We can even create generator*s*, but let's not get too carried away right now and just focus on creating the one.

## Testing a generator

You saw that pun coming, right? Yeah, pretty obvious.
 
We're going to mix it up a bit and add a new feature to our gem: a generator for a _recipes_ directory. The idea is that we can run our generator like this:

    gem_name recipe dinner steak
    
This will generate a _recipes_ directory at the current location, a _dinner_ directory inside that and then a _steak.txt_ file inside that. This _steak.txt_ file will contain the scaffold for a recipe, such as the ingredients and the instructions.

Thankfully for us, Aruba has ways of testing that a generator generates files and directories. Let's create a new file called _features/generator.feature_ and fill it with this content:

    Feature: Generating things
      In order to generate many a thing
      As a CLI newbie
      I want gem_name to hold my hand, tightly
      
      Scenario: Recipes
        When I run "gem_name recipe dinner steak"
        Then the following files should exist:
          | dinner/steak.txt |
        Then the file "dinner/steak.txt" should contain:
          """
            ##### Ingredients #####
            Ingredients for delicious food go here.
            
            
            ##### Instructions #####
            Tips on how to make delicious food go here.
          """
