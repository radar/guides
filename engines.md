# Rails Engines

This guide is designed to show you a step by step process of developing a Rails 3.1 engine by using RSpec, Cucumber, a gem by Jose Valim and of course Rails itself.

This engine, when we're done, will provide forum-like functionality to a pre-existing Rails application. That is to say, *any* pre-existing Rails 3.1 application. That's what an engine does: provide a small "bonus" chunk of functionality to an application, just like the plugins of old did, and do. They are designed to be a drop-in-and-run feature of Rails 3 and they're a great example of "modularity". Drop in, and run. Boom.

Why would you create an engine though? Well, Jose Valim and the plataformatec crew developed Devise as a Rails 3 engine. Devise provides a Rails application with just about all the functionality of a sign-in system you could ever want. It lets users sign in, sign up, reset their password via email and so on. You don't need to "frankenstein" the code into an application: there just needs to be this line in the app's _Gemfile_:

    gem 'devise'
    
When a Rails application starts up with this in its _Gemfile_, Devise will be loaded. Of course to use it, a couple of generators need to be ran. The first is its install generator (`rails g devise:install`) and the second is another generator to generate the model which provides a way to keep track of users in the system. This second generator generates a migration and so we must then run `rake db:migrate`. But then after that, we've got a way for users to sign up and sign in to our application without writing a single line of code.

That's the power of an engine. Our engine will interact with, as said before, a pre-existing Rails application. This application should already have a `User` (or similar) model which we'll use to keep track of things such as the authors of topics and posts in our forums. One problem however is that you need to develop an engine within the context of an application, and Rails itself doesn't come with a way of generating such a scaffold.

Thankfully, Jose Valim's got that covered too.

## enginex

enginex is a gem that Jose Valim's written for his upcoming book, SHAMELESS PROMOTIONAL TITLE AND LINK GOES HERE, which generates a pretty decent scaffold for an engine, including a very bare-bones Rails application inside _spec/dummy_ which we can use to test our engine's functionality.