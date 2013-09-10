# Rails lib files

In Rails's directory structure as far back as I can recall, there's always been a `lib` folder. This folder is for files that don't belong in the `app` folder (not controllers, helpers, mailers, models, observers or views), such as modules that are included into other areas of the application. The `lib` directory is for our code that won't 'fit' in the `app` directory.

You can also see this directory in plugins and engines, as well as in all cool Ruby gems.

In Rails 3, this directory was removed from the autoload path which has lead to some frustration amongst people when their files aren't being automatically loaded. We'll cover what autoloading does in the second part of this rather short and informative guide.

## Using `lib` correctly

We can place any Ruby file in the `lib` directory and require it anywhere in our application, because Rails adds this directory to the `$LOAD_PATH` variable. Let's say we had a file in our application at `lib/wildcard_search.rb` which defined some additional functionality to any model it was included in. Note that this file isn't a model *itself*, it simply provides extensions to models. Therefore it's best to place it in the `lib` directory. Inside this file, the `WildcardSearch` module is defined.

To require this file, we can do this in our application:

    require 'wildcard_search'

Then we've got access to the WildcardSearch module where and when we need it.

## Autoloading with Rails

Don't. Maxim Chernyak has a good write up about `lib` and `app` eager loading:

### If you add a dir directly under app/

Do nothing. All files in this dir are eager loaded in production and lazy loaded in development by default.

### If you add a dir under app/something/

(e.g. app/models/concerns/, app/models/products/)

Ask: do I want to namespace modules and classes inside my new dir?
For example in app/models/products/ you would need to wrap your class in `module Products`.

If the answer is yes, do nothing. It will just work.

If the answer is no, add `config.autoload_paths += %W( #{config.root}/app/models/products )` to your application.rb.

In either case, everything will be eager loaded in production.

### If you add code in your lib/ directory

#### Option 1

If you put something in the lib/ dir, what you are saying is: "I wrote this library, and I want to depend on it where I decide." This means that if you use your library in a rake task, but not in a rails app, you just `require` it in your rake task. If you need this library to always be loaded for your rails app, you `require` it in an initializer. If you need this library for some of your models or controllers, you `require` it in those files, and since everything under your `app/` dir is already auto- and eager- loaded as needed, your library will only be "pulled-in" if something that requires it from `app/` or rake, or your custom script, actually gets loaded.

#### Option 2 (bad)

Another option is to add your whole lib dir into `autoload_paths`: `config.autoload_paths += %W( #{config.root}/lib )`. This means you shouldn't explicitly require your lib anywhere. As soon as you hit the namespace of your dir in other classes, rails will require it. The problem with this is that in Rails 3 if you just add something to your autoload paths it won't get eager loaded in production. You would need to add it to `eager_load_paths` instead, which causes a different problem (see below). And in ruby 1.9 autoload is not threadsafe. You probably want eager loading in production. Requiring your lib explicitly, like in option 1, is akin to eager loading it, which is threadsafe.

#### Option 3 (meh)

All the different things under your lib dir should be placed into their own directories, and those directories should be individually added to `eager_load_paths`.

```
config.eager_load_paths += %W(
  #{config.root}/lib/my_lib1
  #{config.root}/lib/my_lib2
)
```

This means that you can't just throw files into your lib dir. If you have `my_lib1.rb`, you must put it under `my_lib1/my_lib1.rb` and `my_lib1` should be added to eager load paths. This means that if you have more files in `my_lib1`, you should create a dir `my_lib1/my_lib1/extra.rb`. This is a bit annoying.

#### So why not just add lib/ into `eager_load_paths`?

If you add lib/ into `eager_load_paths`, everything will work great. Your files will be autoloaded in development, and eager-loaded in production. Except the problem is that `eager_load_paths` use globbing like `lib/**/*.rb`, meaning that everything in your lib dir will try to get loaded. Your tasks, your generators, everything. This is not what you want.

#### Organizing lib

Regardless of which option you pick (option 1, hint hint), in your lib/ dir you should structure your code as if you structure a gem. If you need more than 1 file, you could for example add a same-named directory where everything is properly namespaced, and let your 1 file relatively require files in that directory.
