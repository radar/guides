# Ecto Basics

This guide is an introduction to [Ecto](https://github.com/elixir-lang/ecto),
the database wrapper and query generator for Elixir. Ecto provides a
standardised API for talking to all the different kinds of databases, so that
Elixir developers can query whatever database they're using in the same
fashion. If one application uses MySQL and another uses PostgreSQL but both
use Ecto, then the database querying for both of those applications will be
almost identical.

If you've come from the Ruby language, the equivalent there would be Active
Record, or Sequel. Java has Hibernate, and so on.

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

That's the first step taken now. We have installed Ecto as a dependency of our
application. We now need to setup some configuration for Ecto so that we can
perform actions on a database from within the application's code.

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

## Querying the database


