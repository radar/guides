# Ecto Basics

This guide is an introduction to [Ecto](https://github.com/elixir-lang/ecto),
the database wrapper and query generator for Elixir. Ecto provides a
standardised API for talking to all the different kinds of databases, so that
Elixir developers can query whatever database they're using in the same
fashion. If one application uses MySQL and another uses PostgreSQL but both
use Ecto, then the database querying for both of those applications will be
almost identical.

If you've come from the Ruby language, the equivalent there would be Active
Record, Data Mapper, or Sequel. Java has Hibernate, and so on.

In this guide, we're going to learn some basics about Ecto, such as creating,
reading, updating and destroying records from a PostgreSQL database. 

**This guide will require you to have setup PostgreSQL beforehand.**

## Adding Ecto to an application

To start off with, we'll generate a new Elixir application by running this command:

```
mix new friends --sup
```

The `--sup` option ensures that this application has [a supervision tree](http://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html), which we'll need for Ecto a little later on.

To add Ecto to this application, there are a few steps that we need to take. The first step will be adding Ecto and an adapter called Postgrex to our `mix.exs` file, which we'll do by changing the `deps` definition in that file to this:

```elixir
defp deps do
  [
    {:ecto, "2.0.0-beta.2"},
    {:postgrex, "0.11.1"}
  ]
end
```

Ecto provides the common querying API, but we need the Postgrex adapter installed too, as that is what Ecto uses to speak in terms a PostgreSQL database can understand.

To install these dependencies, we will run this command:

```
mix deps.get
```

In this same file, we'll need to add `postgrex` to our applications list:

```elixir
def application do
  [applications: [:logger, :postgrex],
   mod: {Friends, []}]
end
```

The Postgrex application will receive queries from Ecto and execute them
against our database. If we didn't do this step, we wouldn't be able to do any
querying at all.

That's the first two steps taken now. We have installed Ecto and Postgrex as
dependencies of our application. We now need to setup some configuration for
Ecto so that we can perform actions on a database from within the
application's code.

The first bit of configuration is going to be in `config/config.exs`. On a new line in this file, put this content

```elixir
config :friends, Friends.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "friends",
  username: "postgres",
  password: "postgres"
```

**NOTE**: Your PostgreSQL database may be setup to not require a username and password. If the above configuration doesn't work, try removing the username and password fields.

This piece of configuration configures how Ecto will connect to our database, called "friends". Specifically, it configures a "repo". More information about [Ecto.Repo can be found in its documentation](https://hexdocs.pm/ecto/Ecto.Repo.html).

The next thing we'll need to do is to setup the repo itself, which goes into `lib/friends/repo.ex`:

```elixir
defmodule Friends.Repo do
  use Ecto.Repo,
    otp_app: :friends
end
```

This module is what we'll be using to query our database shortly. It uses the `Ecto.Repo` module, and the `otp_app` tells Ecto which Elixir application it can look for database configuration in. In this case, we've told it's the `:friends` application where Ecto can find that configuration and so Ecto will use the configuration that we set up in `config/config.exs`.

The final piece of configuration is to setup the `Friends.Repo` as a worker within the application's supervision tree, which we can do in `lib/friends.ex`, inside the `start/2` function:

```elixir
def start(_type, _args) do
  import Supervisor.Spec, warn: false

  children = [
    worker(Friends.Repo, []),
  ]

  ...
```

This piece of configuration will start the Ecto process which receives and executes our application's queries. Without it, we wouldn't be able to query the database at all!

We've now configured our application so that it's able to make queries to our database. Let's now create our database, add a table to it, and then perform some queries.

## Setting up the database

To be able to query a database, it first needs to exist. We can create the database with this command:

```
mix ecto.create
```

If the database has been created successfully, then you will see this message:

```
The database for Friends.Repo has been created.
```

**NOTE:** If you get an error, you should try changing your configuration in `config/config.exs`, as it may be an authentication error.

A database by itself isn't very queryable, so we will need to create a table within that database. To do that, we'll use what's referred to as a _migration_. If you've come from Active Record (or similar), you will have seen these before. A migration is a single step in the process of constructing your database.

Let's create a migration now with this command:

```
mix ecto.gen.migration create_people
```

This command will generate a brand new migration file in `priv/repo/migrations`, which is empty by default:

```elixir
defmodule Friends.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do

  end
end
```

Let's add some code to this migration to create a new table called "people", with a few columns in it:

```elixir
defmodule Friends.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :first_name, :string
      add :last_name, :string
      add :age, :integer
    end
  end
end
```

This new code will tell Ecto to create a new table called people, and add three new fields: `first_name`, `last_name` and `age` to that table. The types of these fields are `string` and `integer`. (The different types that Ecto supports are covered in the [Ecto.Schema](https://hexdocs.pm/ecto/Ecto.Schema.html) documentation.)

**The naming convention for tables in Ecto databases is to use a pluralized name.**

To run this migration and create the `people` table, we will run this command:

```
mix ecto.migrate
```

If we found out that we made a mistake in this migration, we could run `mix ecto.rollback` to undo the changes in the migration. We could then fix the changes in the migration and run `mix ecto.migrate` again. If we ran `mix ecto.rollback` now, it would delete the table that we just created.

We now have a table created in our database. The next step that we'll need to do is to create the schema.

## Creating the schema

The schema is an Elixir representation of data from our database. Each schema doesn't necessarily need to be tied to a table; they can be tied to database views too.

Let's create the schema within our application at `lib/friends/person.ex`:

```elixir
defmodule Friends.Person do
  use Ecto.Schema

  schema "people" do
    field :first_name, :string
    field :last_name, :string
    field :age, :integer
  end
end
```

This model defines the schema from the database that this model maps to. In this case, we're telling Ecto that the `Friends.Person` model maps to the `people` table in the database, and the `first_name`, `last_name` and `age` fields in that table. The second argument passed to `field` tells Ecto how we want the information from the database to be represented in our model.

**We've called this model `Person` because the naming convention in Ecto for models is a singularized name.**

We can play around with this model in an IEx session by starting one up with `iex -S mix` and then running this code in it:

```elixir
person = %Friends.Person{}
```

This code will give us a new `Friends.Person` struct, which will have `nil` values for all the fields. We can set values on these fields by generating a new struct:

```elixir
person = %Friends.Person{age: 28}
```

Or with syntax like this:

```elixir
%{person | age: 28}
```

The model struct returned here is essentially a glorified Map. Let's take a look at how we can insert data into the database.

## Inserting data

We can insert a new record into our `people` table with this code:

```elixir
person = %Friends.Person{}
Friends.Repo.insert person
```

To insert the data into our database, we call `insert` on `Friends.Repo`, which is the module that uses Ecto to talk to our database. The `person` struct here represents the data that we want to insert into the database.

A successful insert will return a tuple, like so:

```elixir
{:ok,
 %Friends.Person{__meta__: #Ecto.Schema.Metadata<:loaded>, age: nil,
  first_name: nil, id: 1, last_name: nil}}
```

The `:ok` atom can be used for pattern matching purposes to ensure that the insert succeeds. A situation where the insert may not succeed is if you have a constraint on the database itself. For instance, if the database had a unique constraint on a field called `email` so that an email can only be used for one person record, then the insertion would fail.

You may wish to pattern match on the tuple in order to refer to the record inserted into the database:

```elixir
{ :ok, person } = Friends.Repo.insert person
```

## Validating changes

In Ecto, you may wish to validate changes before they go to the database. For instance, you may wish that a person has provided both a first name and a last name before a record can be entered into the database. For this, Ecto has [_changesets_](https://hexdocs.pm/ecto/Ecto.Changeset.html).

Let's add a changeset to our `Friends.Person` module inside `lib/friends/person.ex` now:

```elixir
def changeset(person, params \\ :empty) do
  person
  |> cast(params, ~w(first_name last_name))
  |> validate_required([:first_name, :last_name])
end
```

This changeset first casts the `first_name` and `last_name` keys from the parameters passed in to the changeset. Casting tells the changeset what parameters are allowed to be passed through in this changeset, and anything not in the list will be ignored. In this changeset, the `age` parameter will be ignored because it's not specified in the list for `cast`.

On the next line, we call `validate_required` which says that, for this changeset, we expect `first_name` and `last_name` to have values specified. Let's use this changeset to attempt to create a new record without a `first_name` and `last_name`:

```elixir
person = %Friends.Person{}
changeset = Friends.Person.changeset(person, %{})
Friends.Repo.insert changeset
```

On the first line here, we get a struct from the `Friends.Person` module. We know what that does, because we saw it not too long ago. On the second line we do something brand new: we define a changeset. This changeset says that on the specified `person` object, we're looking to make some changes. In this case, we're not looking to change anything at all. 

On the final line, rather than inserting the `person`, we insert the `changeset`. The `changeset` knows about the `person`, the changes and the validation rules that must be met before the data can be entered into the database. When this third line runs, we'll see this:

```elixir
{:error,
 #Ecto.Changeset<action: :insert, changes: %{},
  errors: [first_name: "can't be blank", last_name: "can't be blank"],
  data: #Friends.Person<>, valid?: false>}
```

Just like the last time we did an insert, this returns a tuple. This time however, the first element in the tuple is `:error`, which indicates something bad happened. The specifics of what happend are included in the changeset which is returned. We can access these by doing some pattern matching:

```elixir
{ :error, changeset } = Friends.Repo.insert changeset
```

Then we can get to the errors by doing `changeset.errors`:

```elixir
[first_name: "can't be blank", last_name: "can't be blank"]
```

And we can ask the changeset itself it is valid, even before doing an insert:

```
changeset.valid?
false
```

Since this changeset has errors, no new record was inserted into the `people`
table.

Let's try now with some valid data.

```elixir
person = %Friends.Person{}
changeset = Friends.Person.changeset(person, %{first_name: "Ryan", last_name: "Bigg"})
```

We start out here with a normal `Friends.Person` struct. We then create a changeset for that `person` which has a `first_name` and a `last_name` parameter specified. At this point, we can ask the changeset if it has errors:

```elixir
changeset.errors
[]
```

And we can ask if it's valid or not:

```elixir
changeset.valid?
true
```

The changeset does not have errors, and is valid. Therefore if we try to insert this changeset it will work:

```elixir
{:ok,
 %Friends.Person{__meta__: #Ecto.Schema.Metadata<:loaded>, age: nil,
  first_name: "Ryan", id: 3, last_name: "Bigg"}}
```


Due to `Friends.Repo.insert` returning a tuple, we can use a `case` to determine different code paths depending on what happens:

```elixir
case Friends.Repo.insert(changeset) do
  { :ok, person } ->
    # do something with person
  { :error, changeset } ->
    # do something with changeset
end
```

**NOTE:** `changeset.valid?` will not check constraints (such as `uniqueness_constraint`). For that, you will need to attempt to do an insert and check for errors. It's for this reason it's best practice to try inserting data and validation the returned tuple from `Friends.Repo.insert` to get the correct errors.

If the insertion of the changeset succeeds, then you can do whatever you wish with the `person` returned in that result. If it fails, then you have access to the changeset and its errors. In the failure case, you may wish to present these errors to the end user.

One more final thing to mention here: you can trigger an exception to be thrown by using `Friends.Repo.insert!/2`. If a changeset is invalid, you will see an `Ecto.InvalidChangesetError` exception. Here's a quick example of that:

```
Friends.Repo.insert! Friends.Person.changeset(%Friends.Person{}, %{ first_name: "Ryan" })

** (Ecto.InvalidChangesetError) could not perform insert because changeset is invalid.

* Changeset changes

%{first_name: "Ryan"}

* Changeset params

%{"first_name" => "Ryan"}

* Changeset errors

[last_name: "can't be blank"]

    lib/ecto/repo/schema.ex:111: Ecto.Repo.Schema.insert!/4
```

This exception shows us the changes from the changeset, and how the changeset is invalid. This can be useful if you want to insert a bunch of data and then have an exception raised if that data does not insert correctly at all.

Now that we've covered inserting data into the database, let's look at how we can pull that data back out.

## Querying the database

Querying a database requries two steps in Ecto. First, we must construct the query and then we must execute that query against the database. Let's build a query in our `iex -S mix` session and the execute it against the database. This query will fetch the first person from our `people` table:

```elixir
Friends.Person |> Ecto.Query.first
```

That code will generate an `Ecto.Query`, which will be this:

```
#Ecto.Query<from p in Friends.Person, order_by: [asc: p.id], limit: 1>
```

The code between the angle brackets `<...>` here shows the Ecto query which has been constructed. We could construct this query ourselves with almost exactly the same syntax:

```elixir
require Ecto.Query
Ecto.Query.from p in Friends.Person, order_by: [asc: p.id], limit: 1
```

We need to `require Ecto.Query` here so that the module is available for us to use. Then it's a matter of calling the `from` function from `Ecto.Query` and passing in the code from between the angle brackets. As we can see here, `Ecto.Query.first` saves us from having to specify the `order` and `limit` for the query.

To execute the query that we've just constructed, we can call `Friends.Repo.one`:

```elixir
Friends.Person |> Ecto.Query.first |> Friends.Repo.one
```



## Updating records

## Deleting records

