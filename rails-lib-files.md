# Rails lib files

In Rails's directory structure as far back as I can recall, there's always been a `lib` folder. This folder is for files that don't belong in the `app` folder (not controllers, helpers, mailers, models, observers or views), such as modules that are included into other areas of the application. The `lib` directory is for our code that won't 'fit' in the `app` directory.

In Rails 3, this directory was removed from the autoload path which has lead to some frustration amongst people. We'll cover what autoloading does in the second part of this rather short and informative guide.

## Using `lib` correctly

We can place any Ruby file in the `lib` directory and require it anywhere in our application, because Rails adds this directory to the `$LOAD_PATH` variable. Let's say we had a file in our application at `lib/wildcard_search.rb` which defined some additional functionality to any model it was included in. Note that this file isn't a model *itself*, it simply provides extensions to models. Therefore it's best to place it in the `lib` directory. Inside this file, the `WildcardSearch` module is defined.

To require this file, we can do this in our application:

    require 'wildcard_search'

Then we've got access to the WildcardSearch module where and when we need it.

## Autoloading

Now with autoloading in Rails, we don't need to even require these files to access the constants defined in them. There's a configuration option called `load_paths` for Rails 3 applications which lives in `config/application.rb`, but is commented out by default. We can uncomment this setting and configure it to specify the `lib` directory:

    config.autoload_paths += %W(#{config.root}/lib)

With this setting specified, we don't need to `require` the files in this directory any more, but rather we can simply reference the constants they define and then Rails will require them if it can't find the constants. We can even specify more than one additional path to `autoload_paths` if we choose. ZOMG!

So how does this work? Well, Rails will take the constant name such as `WildcardSearch`, convert it to a string, then call `underscore` before searching for this file in all the `autoload_paths` that are specified. If it finds it, then it will then call `require` on this file and thereby define the constant and if it can't find this file then it will raise an `uninitialized constant` error. If the file is named incorrectly (such as `WildCardSearch.rb` instead), then Rails will be unable to find the file it's looking for, which will cause the constant to not be loaded.

NOTE: If you have a lot of code in `lib` that is not required in your application (e.g. tasks) then you should not add it to `autoload_paths` because they are eager loaded when the application starts and may lead to excessive memory usage. Eager loading of all the files in `autoload paths` is done for thread safety as `require` is inherently unsafe.