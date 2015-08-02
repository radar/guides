# Developing a RubyGem using Bundler

Bundler is a tool created by Carl Lerche, Yehuda Katz, André Arko and various superb contributors for managing Rubygems dependencies in Ruby libraries. Bundler 1.0 was released around the same time as Rails 3 and it's the Rails project where Bundler is probably most well-known usage occurs. But remember, Bundler isn't just for Rails!

Did you know that you can use Bundler for not only gem dependency management but also for writing our own gems? It's really easy to do this and Bundler provides a couple of things to help you along this path.

## But first, why?

Why should we create a gem? Can't we just throw in some code into our *other* library and use that instead? Sure, we can do that. But then what if we want to use the code elsewhere, or we want to share it? This is why a gem is perfect. We can code our library and gem separately from each other and just have the library require the gem. If we want to use the gem in another library, then it's just a tiny modification rather than a whole slew of copying.

Also: Sharing is caring.

## Getting Started

This guide was made using version 1.9.0 of bundler. We can follow along with other versions, but we might not get the exact same output.  To check which version of bundler we currently have, lets run the following command:

    bundle -v

We should see something close to `Bundler version 1.9.0`.  If necessary, we can update to the newest version of Bundler by running `gem update bundler`.

To begin to create a gem using Bundler, use the `bundle gem` command like this:

    bundle gem foodie

We call our gem `foodie` because this gem is going to do a couple of things around food, such as portraying them as either "Delicious!" or "Gross!". Stay tuned.

This command creates a [scaffold directory](gem-scaffold/foodie) for our new gem and, if we have Git installed, initializes a Git repository in this directory so we can start committing right away. If this is your first time running the `bundle gem` command, you will be asked whether you want to include a the `CODE_OF_CONDUCT.md` and `LICENSE.txt` files with your project. The files generated are:

 * [**Gemfile**](gem-scaffold/foodie/Gemfile): Used to manage gem dependencies for our library's development. This file contains a `gemspec` line meaning that Bundler will include dependencies specified in _foodie.gemspec_ too. It's best practice to specify all the gems that our library depends on in the _gemspec_.

 * [**Rakefile**](gem-scaffold/foodie/Rakefile): Requires Bundler and adds the `build`, `install` and `release` Rake tasks by way of calling `Bundler::GemHelper.install_tasks`. The `build` task will build the current version of the gem and store it under the _pkg_ folder, the `install` task will build _and_ install the gem to our system (just like it would do if we `gem install`'d it) and `release` will push the gem to Rubygems for consumption by the public.

 * [**CODE_OF_CONDUCT.md**](gem-scaffold/foodie/CODE_OF_CONDUCT.md): Provides a code of conduct that you expect all contributors to your gem to follow. Will only be included if you chose to have it included.

 * [**LICENSE.txt**](gem-scaffold/foodie/LICENSE.txt): Includes the MIT license. Will only be included if you chose to have it included.

 * [**.gitignore**](gem-scaffold/foodie/.gitignore): (only if we have Git). This ignores anything in the _pkg_ directory (generally files put there by `rake build`), anything with a _.gem_ extension and the _.bundle_ directory.

 * [**foodie.gemspec**](gem-scaffold/foodie/foodie.gemspec): The Gem Specification file. This is where we provide information for Rubygems' consumption such as the name, description and homepage of our gem. This is also where we specify the dependencies our gem needs to run.

 * [**lib/foodie.rb**](gem-scaffold/foodie/lib/foodie.rb): The main file to define our gem's code. This is the file that will be required by Bundler (or any similarly smart system) when our gem is loaded. This file defines a `module` which we can use as a namespace for all our gem's code. It's best practice to put our code in...

 * [**lib/foodie**](gem-scaffold/foodie/lib/foodie): here. This folder should contain all the code (classes, etc.) for our gem. The _lib/foodie.rb_ file is there for setting up our gem's environment, whilst all the parts of it go in this folder. If our gem has multiple uses, separating this out so that people can require one class/file at a time can be really helpful.

 * [**lib/foodie/version.rb**](gem-scaffold/foodie/lib/foodie/version.rb): Defines a `Foodie` module and in it, a `VERSION` constant. This file is loaded by the _foodie.gemspec_ to specify a version for the gem specification. When we release a new version of the gem we will increment a part of this version number to indicate to Rubygems that we're releasing a new version.

There's our base and our layout, now get developing!

## Testing our gem

For this guide, we're going to use RSpec to test our gem. We write tests to ensure that everything goes according to plan and to prevent future-us from building a time machine to come back and kick our asses.

To get started with writing our tests, we'll create a _spec_ directory at the root of gem by using the command `mkdir spec`. Next, we'll specify in our _foodie.gemspec_ file that `rspec` is a development dependency by adding this line inside the `Gem::Specification` block:

```ruby
spec.add_development_dependency "rspec", "~> 3.2"
```

Because we have the `gemspec` method call in our _Gemfile_, Bundler will automatically add this gem to a group called "development" which then we can reference any time we want to load these gems with the following line:

```ruby
Bundler.require(:default, :development)
```

The benefit of putting this dependency specification inside of _foodie.gemspec_ rather than the _Gemfile_ is that anybody who runs `gem install foodie --dev` will get these development dependencies installed too. This command is used for when people wish to test a gem without having to fork it or clone it from GitHub.

When we run `bundle install`, rspec will be installed for this library and any other library we use with Bundler, but not for the system. This is an important distinction to make: any gem installed by Bundler will not muck about with gems installed by `gem install`. It is effectively a sandboxed environment. It is best practice to use Bundler to manage our gems so that we do not have gem version conflicts.

By running `bundle install`, Bundler will generate the **extremely important** _Gemfile.lock_ file. This file is responsible for ensuring that every system this library is developed on has the *exact same* gems so it should always be checked into version control. For more information on this file [read "THE GEMFILE.LOCK" section of the `bundle install` manpage](https://github.com/carlhuda/bundler/blob/1-0-stable/man/bundle-install.ronn#L233-L253).

Additionally in the `bundle install` output, we will see this line:

    Using foodie (0.1.0) from source at /path/to/foodie

Bundler detects our gem, loads the gemspec and bundles our gem just like every other gem.

We can write our first test with this framework now in place. For testing, first we create a folder called _spec_ to put our tests in (`mkdir spec`).  We then create a new RSpec file for every class we want to test at the root of the _spec_ directory. If we had multiple facets to our gem, we would group them underneath a directory such as _spec/facet_; but this is a simple gem, so we won't. Let's call this new file `spec/foodie_spec.rb` and fill it with the following:

```ruby
describe Foodie::Food do
  it "broccoli is gross" do
    expect(Foodie::Food.portray("Broccoli")).to eql("Gross!")
  end

  it "anything else is delicious" do
    expect(Foodie::Food.portray("Not Broccoli")).to eql("Delicious!")
  end
end
```

When we run `bundle exec rspec spec` again, we'll be told the `Foodie::Food` constant doesn't exist. This is true, and we should define it in `lib/foodie/food.rb` like this:

```
module Foodie
  class Food
    def self.portray(food)
      if food.downcase == "broccoli"
        "Gross!"
      else
        "Delicious!"
      end
    end
  end
end
```

To load this file, we'll need to add a require line to `lib/foodie.rb` for it:

```ruby
require 'foodie/food'
```

We will also need to require the `lib/foodie.rb` at the top of `spec/foodie_spec.rb`:

```ruby
require 'foodie'
```

When we run our specs with `bundle exec rspec spec` this test will pass:

    2 example, 0 failures

Great success! If we're using Git (or any other source control system), this is a great checkpoint to commit our code. Always remember to commit often!

It's all well and dandy that we can write our own code, but what if we want to depend on another gem? That's easy too.

## Using other gems

We're now going to use Active Support's `pluralize` method by calling it using a method from our gem.

To use another gem, we must first specify it as a dependency in our _foodie.gemspec_. We can specify the dependency on the `activesupport` gem in _foodie.gemspec_ by adding this line inside the `Gem::Specification` object:

```ruby
spec.add_dependency "activesupport"
```

If we wanted to specify a particular version we may use this line:

```ruby
spec.add_dependency "activesupport", "4.2.0"
```

Or specify a version constraint:

```ruby
spec.add_dependency "activesupport", ">= 4.2.0"
```

However, relying on a version simply greater than the latest-at-the-time is a sure-fire way to run into problems later on down the line. Try to always use `~>` for specifying dependencies:

```ruby
spec.add_dependency "activesupport", "~> 4.2.0"
```

When we run `bundle install` again, the `activesupport` gem will be installed for us to use. Of course, like the diligent TDD/BDD zealots we are, we will test our `pluralize` method before we code it. Let's add this test to *spec/food_spec.rb* now inside our `describe Foodie::Food` block:

```ruby
it "pluralizes a word" do
  expect(Foodie::Food.pluralize("Tomato")).to eql("Tomatoes")
end
```

Of course when we run this spec with `bundle exec rspec spec` it will fail:

    expect(Failure/Error: Foodie::Food.pluralize("Tomato")).to eql("Tomatoes")
         undefined method `pluralize' for Foodie::Food:Class

We can now define this `pluralize` method in _lib/foodie/food.rb_ by first off requiring the part of Active Support which contains the `pluralize` method. This line should go at the top of the file, just like all good `require`s do.

```ruby
require 'active_support/inflector'
```

Next, we can define the `pluralize` method like this:

```ruby
def self.pluralize(word)
  word.pluralize
end
```

When we run `bundle exec rspec spec` our specs will pass:

    3 examples, 0 failures

This brings another checkpoint where it'd be a good idea to commit our efforts so far.

It's great that we're able to call our gem's methods now (all two of them!) and get them to return strings, but everybody knows that the best gems come with command line interfaces (hereafter, "CLI"). You can tell right now just how uncool this gem is because it doesn't have a CLI, right? It needs one. It craves one.

It deserves one.

## Testing a command line interface

Before we go jumping headlong into giving our gem the best darn CLI a gem-with-only-two-methods-that-both-return-useless-strings can have, let's consider how we're going to test this first. We're zealots, remember? Now if only there was a tool we could use. It would have to have a cool name, of course.

Like "Aruba". [BAM](https://github.com/cucumber/aruba)

David Chelimsky and Aslak Hellesøy teamed up to create Aruba, a CLI testing tool, which they both use for RSpec and Cucumber, and now we too can use it for testing our gems. Oh hey, speaking of Cucumber that's also what we're going to be using to define the Aruba tests. Human-code-client-readable tests are the way of the future, man.

We will define new development dependencies in _foodie.gemspec_ now for the Cucumber things:

```ruby
spec.add_development_dependency "cucumber"
spec.add_development_dependency "aruba"
```

Hot. Let's run `bundle install` to get these awesome tools set up.

Our CLI is going to have two methods, which correspond to the two methods which we have defined in `Foodie::Food`. We will now create a _features_ directory where we will make sweet, sweet love to Aruba to write tests for our CLI. In this directory we'll create a new file called _features/food.feature_ and fill it with this juicy code:

```cucumber
Feature: Food
  In order to portray or pluralize food
  As a CLI
  I want to be as objective as possible

  Scenario: Broccoli is gross
    When I run `foodie portray broccoli`
    Then the output should contain "Gross!"

  Scenario: Tomato, or Tomato?
    When I run `foodie pluralize --word Tomato`
    Then the output should contain "Tomatoes"
```

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

We can define them by requiring Aruba. In Cucumber, all _.rb_ files in the _features/support_ directory are automatically required. To prove this to ourselves, we can add a _features/support/setup.rb_ file (create the _support_ directory first) and put in this single line:

```ruby
require 'aruba/cucumber'
```

This loads the Cucumber steps provided by Aruba which are the same steps our Cucumber features need to be awesome.

We have to re-run `bundle exec cucumber features`, just to see what happens next. We see red. Red like the blood incessantly seeping from the walls. It contains this cryptic message:

    sh: foodie: command not found

OK, so it's not *that* cryptic. It just means it can't find the executable file for our gem. No worries, we can create a _exe_ directory at the root of our gem, and put a file in it named _foodie_. This file has no extension because it's an *executable* file rather than a script. We don't want to go around calling `foodie.rb` everywhere, do we? No, no we don't. We will fill this file with this content:

```bash
#!/usr/bin/env ruby
print "nothing."
```

If this file was completely empty, we would run into a non-friendly `Errno::ENOEXEC` error. Hey, speaking of running, we should `chmod` this file to be an executable from our terminal:

    chmod +x exe/foodie

Alright so we've got the executable file, now what? If we re-run our features we get *nothing* for the output. Nothing! Literally!

    got: "nothing."


Our _exe/foodie_ file is empty, which results in this Nothing Travesty. Get rid of the `print "nothing."` line and replace it with all the code required to run our CLI, which consists of two lines:

```ruby
require 'foodie/cli'
Foodie::CLI.start
```

Boom! When we run `bundle exec cucumber features` again it will whinge that there's no _foodie/cli_ file to require. Before we go into what this file does, we should explain the code on the _other_ line of the _exe/foodie_ file. The `start` method fires up our `CLI` class and will look for a task that matches the one we ask for.

 Ok, so it's therefore obvious that the next step is to create this file, but what does it do?

This new _lib/foodie/cli.rb_ file will define the command line interface using another gem called `Thor`. Thor was created by Yehuda Katz (& collaborators) as an alternative to the Rake build tool. Thor provides us with a handy API for defining our CLI, including usage banners and help output. The syntax is very similar to Rake. Additionally, Rails and Bundler both use Thor for their CLI interface as well as their generator base. Yes, Thor even does generators!

For now we'll just look at how we can craft a CLI using Thor and then afterwards, if you behave, we'll look at how to write a generator using it too.

## Crafting a CLI

To make this CLI work we're going to need to create a `Foodie::CLI` class and define a `start` method on it. Or you know, there's probably a gem out there for us to use. Like [Thor](http://github.com/wycats/thor). Named after the badass lightning god from Norse mythology, this gem is definitely on the fast-track to being just as badass. This gem is what we'll be using to build our CLI interface and then later on the generator (if you behave, remember?).

Let's define the `lib/foodie/cli.rb` file now like this:

    require 'thor'
    module Foodie
      class CLI < Thor

      end
    end

The `Thor` class has a series of methods -- such as the `start` method we reference back in `exe/foodie` -- that we can use to create this CLI. Oh, by the way, our class doesn't have to be called `CLI`, it's just best practice to do so. We don't magically get this `Thor` class; we need to tell our _gemspec_ that we depend on this gem by adding this line underneath our previous `add_dependency`:

```ruby
spec.add_dependency "thor"
```

To install this new dependency, we use `bundle install`. When we run `bundle exec cucumber features` again, we'll see that it's now complaining that it could not find the tasks we're calling:

    Could not find task "portray"
    ...
    Could not find task "pluralize"

Thor tasks are defined as plain ol' methods, but with a slight twist. To define the `portray` task in our `Foodie::CLI` class we will write this inside the `Foodie::CLI` class:

```ruby
desc "portray ITEM", "Determines if a piece of food is gross or delicious"
def portray(name)
  puts Foodie::Food.portray(name)
end
```

The `desc` method is the "slight twist" here. The method defined after it becomes a task with the given description. The first argument for `desc` is the usage instructions for the task whilst the second is the short description of what that task accomplishes. The `portray` method is defined with a single argument, which will be the first argument passed to this task on the command line. Inside the `portray` method we call `Foodie::Food.portray` and pass it this argument.

In the `Foodie::CLI` class we're referencing the `Foodie::Food` class without requiring the file that defines it. Under the `require 'thor'` at the top of this file, put this line to require the file that defines `Foodie::Food`:

```ruby
require 'foodie'
```

When we re-run our features using `bundle exec cucumber features` our first scenario will pass:

    2 scenarios (1 failed, 1 passed)
    4 steps (1 failed, 3 passed)

The second is still failing because we haven't defined the `pluralize` task. This time rather than defining a task that takes an argument, we'll define a task that reads in the value from an option passed to the task. To define the `pluralize` task we use this code in `Foodie::CLI`:


```ruby
desc "pluralize", "Pluralizes a word"
method_option :word, :aliases => "-w"
def pluralize
  puts Foodie::Food.pluralize(options[:word])
end
```

Here there's the new `method_option` method we use which defines, well, a method option. It takes a hash which indicates the details of an option how they should be returned to our task. Check out the Thor README for a full list of valid types. We can also define aliases for this method using the `:aliases` option passed to `method_option`. Inside the task we reference the value of the options through the `options` hash and we use `Foodie::Food.pluralize` to pluralize a word.

When we run our scenarios again with `bundle exec cucumber features` both scenarios will be passing:

    2 scenarios (2 passed)
    4 steps (4 passed)

We can try executing the CLI app by running `bundle exec exe/foodie portray broccoli`.

If we want to add more options later on, we can define them by using the `method_options` helper like this:

```ruby
method_options :word => :string, :uppercase => :boolean
def pluralize
  # accessed as options[:word], options[:uppercase]
end
```

In this example, `options[:word]` will return a `String` object, whilst `options[:uppercase]` will return either `true` or `false`, depending on the value it has received.

This introduction should have whet your appetite to learn more about Thor and it's encouraged that you do that now. Check out `Bundler::CLI` for a great example of using Thor as a CLI tool.

With our features and specs all passing now, we're at a good point to commit our code.

It was aforementioned that we could use Thor for more than just CLI. That we could use it to create a generator. This is true. We can even create generator*s*, but let's not get too carried away right now and just focus on creating the one.

## Testing a generator

You saw that pun coming, right? Yeah, pretty obvious.

We're going to mix it up a bit and add a new feature to our gem: a generator for a _recipes_ directory. The idea is that we can run our generator like this:

    foodie recipe dinner steak

This will generate a _recipes_ directory at the current location, a _dinner_ directory inside that and then a _steak.txt_ file inside that. This _steak.txt_ file will contain the scaffold for a recipe, such as the ingredients and the instructions.

Thankfully for us, Aruba has ways of testing that a generator generates files and directories. Let's create a new file called `features/generator.feature` and fill it with this content:


```cucumber
Feature: Generating things
  In order to generate many a thing
  As a CLI newbie
  I want foodie to hold my hand, tightly

  Scenario: Recipes
    When I run `foodie recipe dinner steak`
    Then the following files should exist:
      | dinner/steak.txt |
    Then the file "dinner/steak.txt" should contain:
      """
      ##### Ingredients #####
      Ingredients for delicious steak go here.


      ##### Instructions #####
      Tips on how to make delicious steak go here.
      """
```

It's important to note that the word after "delicious" both times is "steak", which is *very* delicious. It's also the last argument we pass in to the command that we run, and therefore should be a dynamic variable in our template. We'll see how to do this soon.

When we run this feature we'll be told that it cannot find the _dinner/steak.txt_ file that we asked the generator to do. Why not?

## Writing a generator

Well, because currently we don't have a `recipe` task that does this for us defined in `Foodie::CLI`. We can define a generator class just like we define a CLI class:

```ruby
desc "recipe", "Generates a recipe scaffold"
def recipe(group, name)
  Foodie::Generators::Recipe.start([group, name])
end
```

The first argument for this method are the arguments passed to the generator. We will need to require the file for this new class too, which we can do by putting this line at the top of _lib/foodie/cli.rb_:

```ruby
require 'foodie/generators/recipe'
```

To define this class, we inherit from `Thor::Group` rather than `Thor`. We will also need to include the `Thor::Actions` module to define helper methods for our generator which include the likes of those able to create files and directories. Because this is a generator class, we will put it in a new namespace called "generators", making the location of this file _lib/foodie/generators/recipe.rb_:

```ruby
require 'thor/group'
module Foodie
  module Generators
    class Recipe < Thor::Group
      include Thor::Actions

      argument :group, :type => :string
      argument :name, :type => :string
    end
  end
end
```

By inheriting from `Thor::Group`, we're defining a generator rather than a CLI. When we call `argument`, we are defining arguments for our generator. These are the same arguments in the same order they are passed in from the `recipe` task back in `Foodie::CLI`

To make this generator, ya know, generate stuff we simply define methods in the class. All methods defined in a `Thor::Group` descendant will be run when `start` is called on it. Let's define a `create_group` method inside this class which will create a directory using the name we have passed in.

```ruby
def create_group
  empty_directory(group)
end
```

To put the file in this directory and to save our foodie-friends some typing, we will use the `template` method. This will copy over a file from a pre-defined source location and evaluate it as if it were an ERB template. We will define a `copy_recipe` method to do this now:

```ruby
def copy_recipe
  template("recipe.txt", "#{group}/#{name}.txt")
end
```

If we had any ERB calls in this file, they would be evaluated and the result would be output in the new template file.

It's been an awful long time since we ran something. Hey, here's an idea! Let's run our generator! We can do this without using Cucumber by running `bundle exec exe/foodie recipe dinner steak`, but just this once. Generally we'd test it solely through Cucumber. When we run this command we'll be told all of this:

    create  dinner
    Could not find "recipe.txt" in any of your source paths. Please invoke Foodie::Generators::Recipe.source_root(PATH) with the PATH containing your templates. Currently you have no source paths.

The first line tells us that the _dinner_ directory has been created. Nothing too fancy there.

The second line is more exciting though! It's asking us to define the `source_root` method for our generator. That's easy! We can define it as a class method in `Foodie::Generators::Recipe` like this:

```ruby
def self.source_root
  File.dirname(__FILE__) + "/recipe"
end
```

This tells our generator where to find the template. Now all we need to do is to create the template, which we can put at _lib/foodie/generators/recipe/recipe.txt_:

    ##### Ingredients #####
    Ingredients for delicious <%= name %> go here.


    ##### Instructions #####
    Tips on how to make delicious <%= name %> go here.

When we use the `template` method, the template file is treated like an ERB template which is evaluated within the current `binding` which means that it has access to the same methods and variables as the method that calls it.

And that's all! When we run `bundle exec cucumber features` all our features will be passing!

    3 scenarios (3 passed)
    7 steps (7 passed)

Amazing stuff, hey?

## Releasing the gem

If we haven't already, we should commit all the files for our repository:

    git add .
    git commit -m "The beginnings of the foodie gem"

This is because the `foodie.gemspec` file uses `git ls-files` to detect which files should be added to the gem when we release it.

The final step before releasing our gem is to give it a summary and description in the _foodie.gemspec_ file.

Now we're going to make sure that our gem is ready to be published. To do this, we can run `rake build` which will build a local copy of our gem and then `gem install pkg/foodie-0.1.0.gem` to install it. Then we can try it locally by running the commands that it provides. Once we know everything's working, then we can release the first version.

To release the first version of our gem we can use the `rake release` command, providing we have committed everything. This command does a couple of things. First it builds the gem to the _pkg_ directory in preparation for a push to Rubygems.org.

Second, it creates a tag for the current commit reflecting the current version and pushes it to the git remote. It's encouraged that we host the code on GitHub so that others may easily find it.

If this push succeeds then the final step will be the push to Rubygems.org which will now allow other people to download and install the gem.

If we want to release a second version of our gem, we should make our changes and then commit them to GitHub. Afterwards, we will bump the version number in _lib/foodie/version.rb_ to whatever we see fit, make another commit to GitHub with a useful message such as "bumped to 0.0.2" and then run `rake release` again.

If we want to make this process a little easier we could install the "gem-release" gem with:

    gem install gem-release

This gem provides several methods for helping with gem development in general, but most helpful is the `gem bump` command which will bump the gem version to the next patch level. This method also takes options to do these things:

    gem bump --to minor # bumps to the next minor version
    gem bump --to major # bumps to the next major version
    gem bump --to 1.1.1 # bumps to the specified version

For more information, check out the ["gem-release" GitHub repository homepage](http://github.com/svenfuchs/gem-release).

## Summary

Whilst this isn't an _exhaustive_ guide on developing a gem, it covers the basics needed for gem development. It's really, _really_ recommended that you check out the source for Bundler, Rails and RSpec for great examples of gem development.

**If you've found any errors for this guide or if you have any suggestions, please file an issue on http://github.com/radar/guides.**

**I'd like to thank [Andre Arko](http://github.com/indirect) for his involvement in the Bundler project and for answering my questions about it. Without his help, this guide would have been difficult to write.**

** If you're looking for the complete source code for this example it can be found [here](http://github.com/radar/guides/tree/master/gem-development/foodie)**
