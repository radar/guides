# Rails Engines

This guide is designed to show you a step by step process of developing a Rails 3.1 engine by using RSpec, Cucumber, a gem by Jose Valim and of course Rails itself.

This engine, when we're done, will provide forum-like functionality to a pre-existing Rails application. That is to say, *any* pre-existing Rails 3.1 application. That's what an engine does: provide a small "bonus" chunk of functionality to an application, just like the plugins of old did, and do. They are designed to be a drop-in-and-run feature of Rails 3 and they're a great example of "modularity". Drop in, and run. Boom.

Why would you create an engine though? Well, Jose Valim and the plataformatec crew developed Devise as a Rails 3 engine. Devise provides a Rails application with just about all the functionality of a sign-in system you could ever want. It lets users sign in, sign up, reset their password via email and so on. You don't need to "frankenstein" the code into an application: there just needs to be this line in the app's _Gemfile_:

    gem 'devise'
    
When a Rails application starts up with this in its _Gemfile_, Devise will be loaded. Of course to use it, a couple of generators need to be ran. The first is its install generator (`rails g devise:install`) and the second is another generator to generate the model which provides a way to keep track of users in the system. This second generator generates a migration and so we must then run `rake db:migrate`. But then after that, we've got a way for users to sign up and sign in to our application without writing a single line of code.

That's the power of an engine. Our engine will interact with, as said before, a pre-existing Rails application. This application should already have a `User` (or similar) model which we'll use to keep track of things such as the authors of topics and posts in our forums. One problem however is that you need to develop an engine within the context of an application, and Rails itself doesn't come with a way of generating such a scaffold.

Thankfully, Jose Valim's got that covered too.

## enginex

enginex is a gem that Jose Valim's written for his upcoming book, SHAMELESS PROMOTIONAL TITLE AND LINK GOES HERE, which generates a pretty decent scaffold for an engine, including a very bare-bones Rails application inside _spec/dummy_ which we can use to test our engine's functionality. Rather than just simply talking what this gem does, let's see it in action.

Firstly, we're going to need to install the gem which is as easy as using this command:

    gem install enginex
    
This gem provides us with a command called `enginex` which we can use to generate the beginnings of the scaffold for our engine. Our engine's name is an absolutely terrible pun on the word "forum": it's going to be called `for_them`. Let's generate the scaffold now by running using this new command, telling it the (terrible) name of our new engine and passing the option to generate RSpec tests:

    enginex for_them -t rspec --cucumber

By using 

Let's go through what this command actually generates. It operates by a 4-part process, generating slightly different things at each step.

For the first step, this command obviously needs to generate a directory to contain the engine in, and it does. This directory is called _for\_them_, the name that we gave our engine. The first step is setting up the skeleton for our engine to become a gem. By making this engine a gem, we can easily distribute it by uploading it to rubygems.org or rubyforge.org. This step generates the following files:

* _for\_them.gemspec_: (in the future, plainly referenced as "the _gemspec_") Contains a `Gem::Specification` for this engine, setting up things such as the name of the gem, its current version and any of its dependencies for either "real-world" operation or development.
* _Gemfile_: Configuration file for Bundler. Configures "http://rubygems.org" to be the source for all gems and then determines what gems the engine depends on by looking them up from the _gemspec_.
* _lib/for\_them.rb_: Defines a module for our gem called `ForThem` and nothing else. This is the base module where our engine class will be namespaced in.
* _MIT\_LICENSE_: An MIT License file for the gem which is useful if we choose to release it under the MIT License.
* _README.rdoc_: Tells anybody who reads it that the "project rocks and uses the MIT-LICENSE". We can use this to tell users how to install or use our engine.
* _spec/dummy_: A very basic Rails application which we can use to test our engine.
    
