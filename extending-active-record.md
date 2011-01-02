# Extending Active Record

This guide will demonstrate how we can extend Active Record's functionality to provide a couple of new methods on our models which will allow us to find records based on a specified month or year, implementing the same functionality as found in the [by_star][http://github.com/radar/by_star] gem, but in a modern Rails 3 way using the features that Active Record and ARel provide.

This guide assumes you've read the ["Gem Development"][http://github.com/radar/guides/blob/master/gem-development.md] guide which introduces how to develop a basic gem with Bundler. We extensively use the skills learned in that guide in this guide to build this gem, including Bundler and RSpec. 

When we're done here, we'll have a gem that we can add into a Rails application and then be able to call methods on the Active Record models in the application, such as these `by_year` permutations which will find records based on the year passed in:

    Invoice.by_year
    Invoice.by_year(2010, :field => :sent_at)
    
Lastly, we'll add a method which we can call inside classes to set up a default for this gem:

    by_star do
      field :sent_at
    end

## The Beginning

To begin with, we're going to generate a new gem using the `bundle gem` command:

    bundle gem by_star

This command generates the beginning scaffold, but there's something missing... tests! We'll add RSpec to the `by_star.gemspec` file that was generated as a development dependency, changing our development dependencies to now contain both the `bundler` and `rspec` gems:

    s.add_development_dependency "bundler", ">= 1.0.0"
    s.add_development_dependency "rspec", "~> 2.3"
    
We'll also need to add a development dependency for sqlite3-ruby as we'll be using an SQLite3 database for our tests:

    s.add_development_dependency "sqlite3-ruby"
    
Whilst we're in this file we'll add a dependency for Active Record 3, given that we're going to be extending it:

    s.add_dependency "activerecord", "~> 3.0"

To make sure all these gems are now installed we can run `bundle install`.

## Setting up the first test

Our first test is going to implement the first version of the `by_year` method. Let's create the file that will include this test at `spec/lib/by_star_spec.rb` now:

    require 'spec_helper'

    describe "by_star" do
      context "by_year" do
        it "current year" do
          Post.by_year.map(&:text).should include("First post!")
        end
      end
  
    end

For this test to begin to run, we'll need to create the `spec_helper` file it requires on the first line. This file will be responsible for setting up the environment and test data so that our test will run. The first thing this file needs to do is exist at `spec/spec_helper.rb` and the second thing is to set up the test data. We're going to need a database where we can execute queries. We'll begin this file like this:

    require 'by_star'

    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", 
                                           :database => File.dirname(__FILE__) + "/by_star.sqlite3")

The `require` here to the `by_star` (`lib/by_star.rb`) file should load everything that this gem needs to run, including Active Record. We'll modify `lib/by_star.rb` to have a require to load Active Record as its first line now:

    require 'active_record'

With Active Record required, `spec/spec_helper.rb` will be able to use `ActiveRecord::Base.establish_connection` to create a new database located at `spec/by_star.sqlite3`. It's in this database that we'll set up our test data, but to do that we're first going to need to set up the schema for the tables. Underneath the `establish_connection` line in `spec/spec_helper.rb` we'll now put this:

    load File.dirname(__FILE__) + '/support/schema.rb'

This will load the file at `spec/support/schema.rb` which should define the schema for our tables. In this file, we'll put this:

    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :posts, :force => true do |t|
        t.string :text
        t.timestamps
      end
    end

This piece of code will define the schema that we need in our database for us, using the syntax we're familiar with from Rails migrations. Now we'll define the data in a file also in the `spec/support` file, but this time we'll call it `spec/support/data.rb`. We'll keep the data separate because it's easier to manage these two separate from one another. In this file we'll put this:

    Post.create(:text => "First post!")

To define the model, we'll create one more final file at `spec/support/models.rb` and define the `Post` model in this:

    class Post < ActiveRecord::Base

    end

To load this file and `spec/support/data.rb` we'll put these lines in `spec/spec_helper.rb`, right under the other `load`:

    load File.dirname(__FILE__) + '/support/models.rb'
    load File.dirname(__FILE__) + '/support/data.rb'

With the schema, models and data now all set up we should be able run our spec and have it fail because it's missing the `by_year` method now:

    $ bundle exec rspec spec
    F

    Failures:

      1) by_star by_year current year
         Failure/Error: Post.by_year.map(&:text).should include("First post!")
         undefined method `by_year' for #<Class:0x00000101febfd0>
         # ./spec/lib/by_star_spec.rb:6:in `block (3 levels) in <top (required)>'
    
Ah, now it can't find the `by_year` method, so now we get to the extending part.

## Implementing `by_year`

To add these methods to Active Record, we'll use the `extend` method which will add methods from the module to the class, there by *extending* it. Get it? Good. At the bottom of `lib/by_star.rb` we'll add this line:

    ActiveRecord::Base.extend ByStar
    
Now we just need to define the `by_year` method inside the `ByStar` module now. This method should return all objects that are in the given year. For now, we'll just get it to do objects in the current year. Let's define the `by_year` method in the module now:

    module ByStar
      def by_year
        start_time = Time.now.beginning_of_year
        end_time = Time.now.end_of_year
        where(self.arel_table[:created_at].in(start_time..end_time))
      end
    end

Here we get the times at both ends of the year, the very first microsecond and the very last microsecond. Then we call `self.arel_table` which returns an `ARel::Table` object which we can then use to build our queries. We call the `[]` method and pass in `:created_at` as the key and then call the `in` method on that, passing in the beginning and the end of the year. This will construct a `BETWEEN` SQL query for us for the `created_at` column in our `posts` table:

    SELECT "posts".* FROM "posts" WHERE ("posts"."created_at" BETWEEN '2011-01-01 00:00:00.000000' AND '2011-12-31 23:59:59.999999')

That time should be precise enough for anyone! The `by_year` method will return an `ActiveRecord::Relation` object which can then be used for further scoping if the people using our gems want to do something else to it, such as limiting it to return only 5 records by calling it like this:

    Post.by_year.limit(5)

Such is the power of Active Record 3.

With this method defined, let's see if we can have one passing spec now:

    $ ber spec/
    .

    Finished in 0.00169 seconds
    1 example, 0 failures
    
Cool! Next, we'll get it to work with a numbered year and a time object, and then we'll get to passing options to this method.

## A numbered year

We need a new test that will let `by_year` now take a year. Let's add one to the the `context "by_year"` in `spec/lib/by_star_spec.rb`:

    it "a specified year" do
      Post.by_year(Time.now.year - 1).map(&:text).should include("So last year!")
    end

To test this, we're going to need a post from last year. We'll add one to `spec/support/data.rb` now:

    Post.create(:text => "So last year!", :created_at => Time.now - 1.year)

To get `by_year` to support this we will change the method to now take one argument which, defaults to the current year, and use it to construct a `Time` object to use in the method itself.

    def by_year(year=Time.now.year)
      start_time = Date.strptime("#{year}-01-01", "%Y-%m-%d").to_time
      end_time = start_time.end_of_year
      where(self.arel_table[:created_at].in(start_time..end_time))
    end

The `Date.strptime` call here will convert the year into a `Date` object, and then we call `to_time` on it to get a `Time` object, just like the one we got from `Time.now`. Let's see if this makes our spec run now:

    $ ber spec/
    ..

    Finished in 0.00358 seconds
    2 examples, 0 failures

We're just flying through these. The final modification we'll make to how this method is called is get it to take options which will customise what field it does the searching on.

## Methods and options, sitting in a tree

We're going to get the `by_year` method to take a set of options which will modify its behaviour. This set of options will only contain one key, but as it will be a `Hash` object, it leaves it open to taking multiple options at a later stage. Options that are not `:field` (or `'field'` if people feel so inclined) will do nothing. Let's write a new spec for this now in `spec/lib/by_star_spec.rb`:

    
































