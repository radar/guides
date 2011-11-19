This is a detailed guide to the internal workings of Sprockets. Hopefully with this information, somebody else besides Josh Peek, Sam Stephenson, Yehuda Katz and (partially) myself can begin to understand how Sprockets works.

### Sprockets Initialization

To understand Sprockets, we must first understand how it hooks into Rails. Just like with the Active Record and Action Pack components of Rails, Sprockets too has its own railtie. This is included by the `require "rails/all"` call in `config/application.rb` or if you don't have that then it must be required explicitly with `require "sprockets/railtie"`. This railtie is actually kept inside the `actionpack` gem itself, rather than the `sprockets` gem.

The first thing this file does is define the `Sprockets` module and then `autoload` six modules in it.



**rails: actionpack/lib/sprockets/railtie.rb, 6 lines, beginning line 4**
    
    module Sprockets
      autoload :Bootstrap,      "sprockets/bootstrap"
      autoload :Helpers,        "sprockets/helpers"
      autoload :Compressors,    "sprockets/compressors"
      autoload :LazyCompressor, "sprockets/compressors"
      autoload :NullCompressor, "sprockets/compressors"
      autoload :StaticCompiler, "sprockets/static_compiler"

This file then sets up the normal Railtie stuff, such as configuration:



**rails: actionpack/lib/sprockets/railtie.rb, 2 lines, beginning line 12**
    
    class Railtie < ::Rails::Railtie
      config.action_controller.default_asset_host_protocol = :relative

This configuration option is caught by the `config` options `method_missing` which will then store this setting in the configuration hash for the application. It is retreivable by calling simply `Rails.application.config.default_asset_host_protocol` again.

Next, this Railtie defines some rake tasks:



**rails: actionpack/lib/sprockets/railtie.rb, 3 lines, beginning line 15**
    
    rake_tasks do
      load "sprockets/assets.rake"
    end

This `sprockets/assets.rake` file provides the `assets:precompile` and `assets:clean` Rake tasks we will see later on in this internals guide.

After that, the Railtie defines an initializer, which will be appended onto the list of initializers currently at this point of Rails. Currently, this initializer will run directly after ActiveResource's initializers have run. Inside this initializer, there's a check first if Rails should even bother with loading sprockets at all:



**rails: actionpack/lib/sprockets/railtie.rb, 2 lines, beginning line 19**
    
    config = app.config
    next unless config.assets.enabled

This is the `Rails.application.config.assets.enabled` flag. If it is set to a non-truthy value then this initializer will stop right there. By default though, it's enabled and so it will continue.

After this point, then sprockets is required and a new `Sprockets::Environment` object is set up:



**rails: actionpack/lib/sprockets/railtie.rb, 3 lines, beginning line 18**
    
    require 'sprockets'
    
    app.assets = Sprockets::Environment.new(app.root.to_s) do |env|

The `initialize` method in `Sprockets::Environment` will receive the application's root. The `initialize` method in `Sprockets::Environment` is quite long and sets up a lot of the functionality. It begins by creating a new `Hike::Trail` object out of the root of the application that was passed in and setting a default logger:



**sprockets: lib/sprockets/environment.rb, 5 lines, beginning line 20**
    
    def initialize(root = ".")
      @trail = Hike::Trail.new(root)
    
      self.logger = Logger.new($stderr)
      self.logger.level = Logger::FATAL

This then sets up a new class that inherits from `Sprockets::Context` class, defines a digest class and defaults the versioning to a blank string:



**sprockets: lib/sprockets/environment.rb, 6 lines, beginning line 27**
    
    @context_class = Class.new(Context)
    
    # Set MD5 as the default digest
    require 'digest/md5'
    @digest_class = ::Digest::MD5
    @version = ''

This context class is used by the bundled asset feature in sprockets, which we'll see in greater detail later in this guide. The `@digest_class` variable is used to determine what digest class should be used to provide unique identifiers for precompiled assets, such as those generated with `rake assets:precompile`. Finally, `@version` will be used to provide a manually overridable string for the assets versions. We can change this in `config.assets.version` in `config/application.rb` to expire all our assets manually.

Next, the `initialize` method sets up more default values:



**sprockets: lib/sprockets/environment.rb, 5 lines, beginning line 34**
    
    @mime_types        = {}
    @engines           = Sprockets.engines
    @preprocessors     = Hash.new { |h, k| h[k] = [] }
    @postprocessors    = Hash.new { |h, k| h[k] = [] }
    @bundle_processors = Hash.new { |h, k| h[k] = [] }

We'll see what the mime types, pre-processors, post-processors and bundle processors are in just a bit, but first let's see what `Sprockets.engines` is. This method is defined in `lib/sprockets/engines.rb` which is loaded with the `lib/sprockets.rb` file that was required by the Railtie. The `lib/sprockets/engines.rb` file defines the `Sprockets::Engines` module and defines the `engines` method like this:



**sprockets: lib/sprockets/engines.rb, 8 lines, beginning line 41**
    
    def engines(ext = nil)
      if ext
        ext = Sprockets::Utils.normalize_extension(ext)
        @engines[ext]
      else
        @engines.dup
      end
    end

When this method is called with no arguments, like in `Sprockets::Environment`'s `initialize` method, it will return a duplicated object of the engines currently registered with Sprockets. These engines are the templating engines that Sprockets will make use of in the asset pipeline. These should not be confused with the "engines" that Rails has. The ones for Sprockets are *templating engines*, where the ones in Rails are more like miniature applications.

Now, it may *seem* like that there are no engines registered with Sprockets at the moment, there actually is. At the bottom of the `lib/sprockets/engines.rb` file, the `Sprockets` module is extended by the `Engines` module contained within (this is how the `engines` method is then provided for `Sprockets`) and then these default engines are registered: 



**sprockets: lib/sprockets.rb, 22 lines, beginning line 41**
    
      extend Engines
      @engines = {}
    
      # Cherry pick the default Tilt engines that make sense for
      # Sprockets. We don't need ones that only generate html like HAML.
    
      # Mmm, CoffeeScript
      register_engine '.coffee', Tilt::CoffeeScriptTemplate
    
      # JST engines
      register_engine '.jst',    JstProcessor
      register_engine '.eco',    EcoTemplate
      register_engine '.ejs',    EjsTemplate
    
      # CSS engines
      register_engine '.less',   Tilt::LessTemplate
      register_engine '.sass',   Tilt::SassTemplate
      register_engine '.scss',   Tilt::ScssTemplate
    
      # Other
      register_engine '.erb',    Tilt::ERBTemplate
      register_engine '.str',    Tilt::StringTemplate

All of these engines inherit from `Tilt::Template` which will be used to render these templates. The `register_engine` method is also defined within the `lib/sprockets/engines.rb` file and goes like this:



**sprockets: lib/sprockets/engines.rb, 4 lines, beginning line 63**
    
    def register_engine(ext, klass)
      ext = Sprockets::Utils.normalize_extension(ext)
      @engines[ext] = klass
    end

This method calls `Sprockets::Utils.normalize_extension` to, uh, normalize the extension by doing this:



**sprockets: lib/sprockets/utils.rb, 8 lines, beginning line 58**
    
    def self.normalize_extension(extension)
      extension = extension.to_s
      if extension[/^\./]
        extension
      else
        ".#{extension}"
      end
    end

This way, you can call `register_engine` and pass it an extension for that template *with or without* the dot prefix and this method will prefix the dot. Once `normalize_extension` has done its thing, then `register_engine` finishes by adding a new key to the `@engines` hash with the new extension and the specified class.

Going back to `lib/sprockets/environment.rb` now, and the next thing that happens is that these engines are added to the trail:



**sprockets: lib/sprockets/environment.rb, 3 lines, beginning line 40**
    
    @engines.each do |ext, klass|
      add_engine_to_trail(ext, klass)
    end

The `add_engine_to_trail` method is defined in `lib/sprockets/processing.rb` beginning like this:



**sprockets: lib/sprockets/processing.rb, 2 lines, beginning line 270**
    
    def add_engine_to_trail(ext, klass)
      @trail.append_extension(ext.to_s)

The `@trail` object was originally set up earlier in the `initialize` method for our new `Sprockets::Environment` object, and is a `Hike::Trail` object. Therefore, this `append_extension` method is defined within Hike and not Sprockets. It is defined within `lib/hike/trail.rb` very simply:



**hike: lib/hike/trail.rb, 4 lines, beginning line 84**
    
    def append_extensions(*extensions)
      self.extensions.push(*extensions)
    end
    alias_method :append_extension, :append_extensions

This is so that Hike will be able to find files with the given extensions when they are searched for later on in this process.

Now that we know what the `Sprockets.engines` method does, we've still got the remainder of the `initialize` method for `Sprockets::Environment` to figure out. The next two lines in this method register mime types for CSS and JavaScript:



**sprockets: lib/sprockets/environment.rb, 2 lines, beginning line 44**
    
    register_mime_type 'text/css', '.css'
    register_mime_type 'application/javascript', '.js'

This method works very similarly to the `register_engine` method we saw earlier, which was defined in `lib/sprockets/engines.rb'. The `register_mime_type` method is defined in `lib/sprockets/mime.rb` like this:



**sprockets: lib/sprockets/mime.rb, 4 lines, beginning line 29**
    
    def register_mime_type(mime_type, ext)
      ext = Sprockets::Utils.normalize_extension(ext)
      @mime_types[ext] = mime_type
    end

This calls `normalize_extension` again which will of course prefix the extension with a dot if it didn't have one. In this case though, there are dots. A new key is added to the `@mime_types` hash with this new extension with the `mime_type` being its value.

Next in the `Sprockets::Environment#initialize` method, the `register_preprocessor` method is called:



**sprockets: lib/sprockets/environment.rb, 2 lines, beginning line 47**
    
    register_preprocessor 'text/css', DirectiveProcessor
    register_preprocessor 'application/javascript', DirectiveProcessor

The `DirectiveProcessor` is the class that is responsible for parsing the `*= require 'blah'` and `//= require 'other_blah'` directives in our JavaScript and CSS files. We'll see the inner workings of this when we are going through the process of serving an asset.

The `register_preprocessor` method is a little more complicated than the `register_engine` and `register_mime_types` method, and it is defined within `lib/sprockets/processing.rb`:



**sprockets: lib/sprockets/processing.rb, 13 lines, beginning line 90**
    
    def register_preprocessor(mime_type, klass, &amp;block)
      expire_index!
    
      if block_given?
        name  = klass.to_s
        klass = Class.new(Processor) do
          @name      = name
          @processor = block
        end
      end
    
      @preprocessors[mime_type].push(klass)
    end

First, the `expire_index!` method is called. This method is defined in `lib/sprockets/environment.rb` and does the following: 



**sprockets: lib/sprockets/environment.rb, 5 lines, beginning line 87**
    
    def expire_index!
      # Clear digest to be recomputed
      @digest = nil
      @assets = {}
    end

This method ensures that our index is at a pristine state, where the digest has not yet been computed and there have been no assets served.

After the pre-processor has been registered, a single post-processor is registered:



**sprockets: lib/sprockets/environment.rb, 1 lines, beginning line 50**
    
    register_postprocessor 'application/javascript', SafetyColons

This class is responsible for adding semi-colons to the end of each file before they are concatenated into a single bundle. Without this, it could lead to JavaScript syntax errors.

Next, a bundle processor is added for CSS files:



**sprockets: lib/sprockets/environment.rb, 1 lines, beginning line 51**
    
    register_bundle_processor 'text/css', CharsetNormalizer

Bundle processors are run after the assets are concatenated. This one searches for `@charset` definitions in CSS files, keeps the first one and strips out the rest. Otherwise, multiple charset specifications will lead to undesired results. For more information, check out the comments on the `Sprockets::CharsetNormalizer` class.

After `register_bundle_processor` runs, `expire_index!` is run again just for good measure and the new object is yielded if block is given to this method, which it is.



**sprockets: lib/sprockets/environment.rb, 3 lines, beginning line 53**
    
    expire_index!
    
    yield self if block_given?

When `yield` is called, it will evaluate the block it is given using the code specified back in `actionpack/lib/sprockets/railtie.rb`:



**rails: actionpack/lib/sprockets/railtie.rb, 8 lines, beginning line 25**
    
    app.assets = Sprockets::Environment.new(app.root.to_s) do |env|
      env.logger  = ::Rails.logger
      env.version = ::Rails.env + "-#{config.assets.version}"
    
      if config.assets.cache_store != false
        env.cache = ActiveSupport::Cache.lookup_store(config.assets.cache_store) || ::Rails.cache
      end
    end

This block takes the object that is given by `yield` and sets the `logger` to be the `Rails.logger` and the version to be a combination of the Rails environment's name and the `config.assets.version` setting, which is "1.0" by default in `config/application.rb`. Next, it sets up a cache for the assets (only if `config.assets.cache_store` is not exactly `false`), using the value specified in `config.assets.cache_store` or alternatively using the `Rails.cache` settings.

So as we can see here, by default the Sprockets environment will use the same logger and cache as the application itself, but we can configure these if we please.

That's the end of the `"sprockets.environment"` initializer now. The next thing the Railtie does is declare an assets manifest file.



**rails: actionpack/lib/sprockets/railtie.rb, 9 lines, beginning line 34**

      if config.assets.manifest
        path = File.join(config.assets.manifest, "manifest.yml")
      else
        path = File.join(Rails.public_path, config.assets.prefix, "manifest.yml")
      end

      if File.exist?(path)
        config.assets.digests = YAML.load_file(path)
      end

If the directory where the manifest file will reside is provided in `config.assets.manifest` settings, it will use a `manifest.yml` file under that directory. Else it will fall back to `public` directory of the application and assume `manifest.yml` to be available there. After setting the path to assets manifest file, it will parse this file and put options under `config.assets.digest`.

After all this, Railtie will now add a hook for when Action View is loaded using these lines:



**rails: actionpack/lib/sprockets/railtie.rb, 7 lines, beginning line 44**
    
    ActiveSupport.on_load(:action_view) do
      include ::Sprockets::Helpers::RailsHelper
      app.assets.context_class.instance_eval do
        include ::Sprockets::Helpers::IsolatedHelper
        include ::Sprockets::Helpers::RailsHelper
      end
    end

The `on_load` method is used to add hooks for certain components used within a Rails application. In this usage, when Action View is loaded then the `Sprockets::Helpers::RailsHelper` module is included into `ActionView::Base`. Also inside this block, the environment's `context_class` is referenced (remember, it's a new anonymous class inheriting from `Sprockets::Context`) and `Sprockets::Helpers::IsolatedHelper` and `Sprockets::Helpers::RailsHelper` modules are included on that also.

Finally in the Railtie an `after_initialize` hook is defined. It begins like this:



**rails: actionpack/lib/sprockets/railtie.rb, 2 lines, beginning line 57**
    
    config.after_initialize do |app|
      Sprockets::Bootstrap.new(app).run

It first initializes a `Sprockets::Bootstrap` object by passing it our application and then calls `run` on that object. Initialization of a `Sprockets::Bootstrap` object is fairly simple.



**rails: actionpack/lib/sprockets/bootstrap.rb, 2 lines, beginning line 3**

    def initialize(app)
      @app = app
    end

It puts the application under `@app` variable.

The `run` method on `Sprockets::Bootstrap` is quite long. It begins with setting up paths where our assets will reside in the application.



**rails: actionpack/lib/sprockets/bootstrap.rb, 4 lines, beginning line 9**

      app, config = @app, @app.config
      return unless app.assets

      config.assets.paths.each { |path| app.assets.append_path(path) }


      next unless app.assets
      config = app.config
    
      config.assets.paths.each { |path| app.assets.append_path(path) }

It first sets up a `config` variable so that code doesn't make continual references to `@app.config`. This method skips further processing if `app.assets` is set to `false`, but by default this is not the case and so let's assume it's not. Finally in the above example, the `config.assets.paths` collection is iterated through with each path being used in an `append_path` call on the `app.assets` object, which is the `Sprockets::Environment` object that was set up earlier.

The `config.assets.paths` are set up inside of Rails at `railties/lib/rails/engine.rb` using these lines:



**rails: railties/lib/rails/engine.rb, 5 lines, beginning line 545**
    

    initializer :append_assets_path, :group => :all do |app|
      app.config.assets.paths.unshift(*paths["vendor/assets"].existent_directories)
      app.config.assets.paths.unshift(*paths["lib/assets"].existent_directories)
      app.config.assets.paths.unshift(*paths["app/assets"].existent_directories)
    end

When the Rails application is initialized, The asset directories inside of `vendor/assets`, `lib/assets` and `app/assets` paths will be added to `config.assets.paths`, but only if these directories exist.

The `append_path` method on instances of `Sprockets::Environment` is defined in `lib/sprockets/trail.rb` and does the following:



**sprockets: lib/sprockets/trail.rb, 4 lines, beginning line 38**
    
    def append_path(path)
      expire_index!
      @trail.append_path(path)
    end

This calls the `expire_index` to clear the index, as it is potentially adding new assets, and then calls `append_path` on the `@trail` object, which is an instance of `Hike::Trail`. The `append_path` method for `Hike::Trail` is defined like this:



**hike: lib/hike/trail.rb, 4 lines, beginning line 67**
    
    def append_paths(*paths)
      self.paths.push(*paths)
    end
    alias_method :append_path, :append_paths

The `self.paths` in this case is an array of paths, and so `push` will just add those paths to the end of the array.

The next line in the `Sprockets::Bootstrap#run` checks to see if the `config.assets.compress` setting is set to a truthy value. By default, it isn't in the development environment but is in the production environment.



**rails: actionpack/lib/sprockets/bootstrap.rb, 11 lines, beginning line 14**
    
      if config.assets.compress
        # temporarily hardcode default JS compressor to uglify. Soon, it will work
        # the same as SCSS, where a default plugin sets the default.
        unless config.assets.js_compressor == false
          app.assets.js_compressor = LazyCompressor.new { Sprockets::Compressors.registered_js_compressor(config.assets.js_compressor || :uglifier) }
        end

        unless config.assets.css_compressor == false
          app.assets.css_compressor = LazyCompressor.new { Sprockets::Compressors.registered_css_compressor(config.assets.css_compressor) }
        end
      end

If the setting is truthy then it will determine if there is a `js_compressor` setting or a `css_compressor` setting. For the `js_compressor` setting, the `Sprockets::Compressors.registered_js_compressor` method is used, which is defined like this:



**rails: actionpack/lib/sprockets/compressor.rb, 9 lines, beginning line 28**
    
    def self.registered_js_compressor(name)
      if name.respond_to?(:to_sym)
        compressor = @@js_compressors[name.to_sym] || @@js_compressors[@@default_js_compressor]
        require compressor[:require] if compressor[:require]
        compressor[:klass].constantize.new
      else
        name
      end
    end

It looks up for a javascript compressor in `@@js_compressors` class variable. If it does not find the compressor corresponding to the name passed, it fallbacks to the `@@default_js_compressor`. The `@@js_compressors` and `@@default_js_compressor` class variable are initialied when `Sprockets::Compressor` class is loaded and `register_js_compressor` method is called on it. After fetching a compressor, it will require the required files and return the class used for compression. The gems that provide these files *must* be specified within the `Gemfile` of the application before they can be loaded.

**rails: actionpack/lib/sprockets/compressor.rb, 1 lines, beginning line 40**



    register_js_compressor(:uglifier, 'Uglifier', :require => 'uglifier', :default => true)

This registers `uglifier` as the default js compressor. It does not stop here and registers some more js compressors

**rails: actionpack/lib/sprockets/compressor.rb, 2 lines, beginning line 44**



    register_js_compressor(:closure, 'Closure::Compiler', :require => 'closure-compiler')
    register_js_compressor(:yui, 'YUI::JavaScriptCompressor', :require => 'yui/compressor')

It registers `:closure` and `:yui` compressors also. `Sprockets::Compressor.register_js_compressor` puts class and require directive under passed name in `@@js_compressors` hash and `@@default_js_compressor` class variable.

**rails: actionpack/lib/sprockets/compressor.rb, 15 lines, beginning line 13**



    def self.register_js_compressor(name, klass, options = {})
      @@default_js_compressor = name.to_sym if options[:default] || @@default_js_compressor.nil?
      @@js_compressors[name.to_sym] = {:klass => klass.to_s, :require => options[:require]}
    end

`Sprockets::Bootstrap#run` will now continue to register the `css_compressor`. The `Sprockets::Compressor.registered_css_compressor` method is similar to `Sprockets::Compressor.registered_js_compressor`, except that it looks for compressors in `@@css_compressors` and default css compressor in `@@default_css_compressor` class variable:



**rails: actionpack/lib/sprockets/compressor.rb, 9 lines, beginning line 18**
    
    def self.registered_css_compressor(name)
      if name.respond_to?(:to_sym)
        compressor = @@css_compressors[name.to_sym] || @@css_compressors[@@default_css_compressor]
        require compressor[:require] if compressor[:require]
        compressor[:klass].constantize.new
      else
        name
      end
    end

`Sprockets::Compressor` registers `scss` as default and `yui` as another css compressor. `Sprocets::Compressor.register_css_compressor` method is used to register these compressors.

These compressor objects are then passed to `LazyCompressor.new` inside a block. The purpose of this is to provide a way to compress content if a compressor is specified, or otherwise falback to a `Sprockets::NullCompressor` class which just returns the content as-is. We can see the code for this in `actionpack/lib/sprockets/compressors.rb`:



**rails: actionpack/lib/sprockets/compressors.rb**
    
    module Sprockets
      class NullCompressor
        def compress(content)
          content
        end
      end
    
      class LazyCompressor
        def initialize(&block)
          @block = block
        end
    
        def compress(content)
          compressor.compress(content)
        end

        private

        def compressor
          @compressor ||= (@block.call || NullCompressor.new)
        end
      end
    end

Next up in this `Sprockets::Bootstrap#run` call, the routes are prepended with a route to the assets using these lines:



**rails: actionpack/lib/sprockets/bootstrap.rb, 5 lines, beginning line 26**
    
    if config.assets.compile
      app.routes.prepend do
        mount app.assets => config.assets.prefix
      end
    end

The `routes` object here is the same `routes` object normally returned by `Rails.application.routes`, famously used in declaring routes for an application in `config/routes.rb`. The `prepend` method on this object is a new feature of Rails 3.1 and just like its name implies it will append a set of routes to the beginning of the routing table. This means that the `/assets` route will now be the first route that is matched in the application. The `app.assets` object is the `Sprockets::Environment` object set up before, and the `config.assets.prefix` value defaults to `/assets/`.

Finally in the `run` call, there's a check to see if assets are performing digest:



**rails: actionpack/lib/sprockets/railtie.rb, 3 lines, beginning line 32**
    
    if config.assets.digest
      app.assets = app.assets.index
    end

The `index` method on `Sprockets::Environment` does this:



**sprockets: lib/sprockets/environment.rb, 3 lines, beginning line 63**
    
    def index
      Index.new(self)
    end

The `Index` class's purpose is to provide a cached version for the environment, which makes the calls to the file system much faster as it will be caching the location of the assets, rather than looking them up each time they are requested. Of course, in the `development` environment the `perform_caching` setting is set to `false` and so it's disabled, but in production it will be enabled.

And that's the `Sprockets::Railtie` class covered. This section has described how Sprockets attaches to Rails and provides the beginnings of the asset pipeline. One of the features we saw inside this Railtie was that it included modules into `ActionView::Base`. The purpose of this is to provide overrides for methods such as `javascript_include_tag`, `image_tag` and `stylesheet_link_tag` so that they use the asset pipeline, rather than the default Rails helpers which do not.

Let's take a look at these now.

### Sprockets Asset Helpers

Within Rails 3.1, the behaviour of `javascript_include_tag` and `stylesheet_link_tag` are modified by the `actionpack/lib/sprockets/helpers/rails_helper.rb` file which is required by `actionpack/lib/sprockets/railtie.rb`, which itself is required by `actionpack/lib/action_controller/railtie.rb` and so on, and so forth.

The `Sprockets::Helpers::RailsHelper` is included into ActionView through the process described in my earlier [Sprockets Railtie Setup](https://gist.github.com/1032696) internals doc. Once this is included, it will override the `stylesheet_link_tag` and `javascript_include_tag` methods originally provided by Rails itself. Of course, if assets were disabled (`Rails.application.config.assets.enabled = false`) then the original Rails methods would be used and JavaScript assets would then exist in `public/javascripts`, not `app/assets/javascripts`. Let's just assume that you're using Sprockets.

Let's take a look at the `stylesheet_link_tag` method from `Sprockets::Helpers::RailsHelper`. The `javascript_include_tag` method is very similar so if you want to know how that works, just replace `stylesheet_link_tag` with `javascript_include_tag` using your *mind powers* and I'm sure you can get the gist of it.

#### What `stylesheet_link_tag` / `javascript_include_tag` does

This method begins like this: 



**rails: actionpack/lib/sprockets/helpers/rails_helper.rb, 5 lines, beginning line 37**
    
    def stylesheet_link_tag(*sources)
      options = sources.extract_options!
      debug = options.key?(:debug) ? options.delete(:debug) : debug_assets?
      body  = options.key?(:body)  ? options.delete(:body)  : false
      digest  = options.key?(:digest)  ? options.delete(:digest)  : digest_assets?

The first argument for `stylesheet_link_tag` is a splatted `sources` which means that this method can take a list of stylesheets or manifest files and will process each of them. The method also takes some `options`, which are extracted out on the first line of this method using `extract_options!`. The three currently supported are `debug`, `body` and `digest`.

The `debug` option will expand any manifest file into its contained parts and render each file individually. For example, in a project I have here, this line:

    <%= stylesheet_link_tag "application" %>

When a request is made to this page that uses this layout that renders this file, it will be printed as a single line:
    
    <link href="/assets/application.css" media="screen" rel="stylesheet" type="text/css"> 

Even though the file it's pointing to contains *directives* to Sprockets to include everything in `app/assets/stylesheets`:

    *= require_self
    *= require_tree .

What sprockets is doing here is reading this manifest file and compiling all the CSS assets specified into one big fuck-off file and serving just that instead of the \*counts\* 13 CSS files I've got in that directory.

This helper then iterates through the list of sources specified and first dives in to checking the `debug` option. If `debug` is set to true for this though, either through `options[:debug]` being passed or by `debug_assets?` evaluating to `true`, this will happen:



**rails: actionpack/lib/sprockets/helpers/rails_helper.rb, 5 lines, beginning line 43**

    sources.collect do |source|
      if debug && asset = asset_paths.asset_for(source, 'css')
        asset.to_a.map { |dep|
          super(dep.to_s, { :href => asset_path(dep, :ext => 'css', :body => true, :protocol => :request, :digest => digest) }.merge!(options))
        }

The `super` method here will call the `stylesheet_link_tag` method defined in `ActionView::Helpers::AssetTagHelper`. This is the default `stylesheet_link_tag` method that would be called if we didn't have Sprockets enabled.

The `debug_assets?` method is defined as a private method further down in this file:



**rails: actionpack/lib/sprockets/helpers/rails_helper.rb, 7 lines, beginning line 75**
    
    private
      def debug_assets?
        compile_assets? && (Rails.application.config.assets.debug || params[:debug_assets])
      rescue NoMethodError
        false
      end

If `compile_assets?` is true and one of `Rails.application.config.assets.debug` or `debug_assets` parameter in the request is present then the assets will be *debugged*. `compile_assets?` method is defined below `debug_assets?` method. It checks if the value of `Rails.application.config.assets.compile` with truthy. There *may* be a case where `params` doesn't exist, and so this method rescues a potential `NoMethodError` that could be thrown. Although I can't imagine a situation in Rails where that would ever be the case.

Back to the code within `stylesheet_link_tag`, this snippet will get all the assets specified in the manifest file, iterate over each of them and render a `stylesheet_link_tag` for each of them, ensuring that `:debug` is set to false for them.

It's important to note here that the CSS files that the original `app/assets/stylesheets/application.css` points to can each be their own manifest file, and so on and so forth.

If the `debug` option isn't specified and `debug_assets?` evaluates to `false` then the `else` for this `if` will be executed:



**rails: actionpack/lib/sprockets/helpers/rails_helper.rb, 3 lines, beginning line 48**
    
    else
      super(source.to_s, { :href => asset_path(source, :ext => 'css', :body => body, :protocol => :request, :digest => digest) }.merge!(options))
    end

This will render just the one line, rather than expanding the dependencies of the stylesheet. This calls the `asset_path` method which is defined like this:



**rails: actionpack/lib/sprockets/helpers/rails_helper.rb, 5 lines, beginning line 54**
    
    def asset_path(source, options = {})
      source = source.logical_path if source.respond_to?(:logical_path)
      path = asset_paths.compute_public_path(source, asset_prefix, options.merge(:body => true))
      options[:body] ? "#{path}?body=1" : path
    end

(WIP: I don't know what `logical_path` is for, so let's skip over that for now. In my testing, `source` has always been a `String` object).

This method then calls out to `asset_paths` which is defined at the top of this file:



**rails: actionpack/lib/sprockets/helpers/rails_helper.rb, 11 lines, beginning line 9**
    
      def asset_paths
        @asset_paths ||= begin
          paths = RailsHelper::AssetPaths.new(config, controller)
          paths.asset_environment = asset_environment
          paths.asset_digests     = asset_digests
          paths.compile_assets    = compile_assets?
          paths.digest_assets     = digest_assets?
          paths
        end
      end

This method (obviously) initializes a new instance of the `RailsHelper::AssetPaths` class defined later in this file, passing through the `config` and `controller` objects of the current content, which would be the same `self.config` and `self.controller` available within a view.

This `RailsHelper::AssetPaths` inherits behaviour from `ActionView::AssetPaths`, which is responsible for resolving the paths to the assets for vanilla Rails. The `RailsHelper::AssetPaths` overrides some of the methods defined within its superclass, though. 

The `asset_environment` method is defined also in this file:



**rails: actionpack/lib/sprockets/helpers/rails_helper.rb, 3 lines, beginning line 107**
    
    def asset_environment
      Rails.application.assets
    end

The `assets` method called inside the `asset_environment` method returns a `Sprockets::Index` instance, which we'll get to later.

The `asset_digest` and `digest_assets?` both return `Rails.application.config.assets.digests`
 


**rails: actionpack/lib/sprockets/helpers/rails_helper.rb, 3 lines, beginning line 92**
    
    def asset_digests
      Rails.application.config.assets.digests
    end

The `compile_assets?` returns `Rails.application.config.assets.compile`



**rails: actionpack/lib/sprockets/helpers/rails_helper.rb, 3 lines, beginning line 96**

    def compile_assets?
      Rails.application.config.assets.compile
    end

The next method is `compute_public_path` which is called on this new `RailsHelper::AssetPaths` instance. This is defined simply in `ActionView::AssetPaths`:



**rails: actionpack/lib/action_view/asset_paths.rb, 20 lines, beginning line 22**
    
    # Add the extension +ext+ if not present. Return full or scheme-relative URLs otherwise untouched.
    # Prefix with <tt>/dir/</tt> if lacking a leading +/+. Account for relative URL
    # roots. Rewrite the asset path for cache-busting asset ids. Include
    # asset host, if configured, with the correct request protocol.
    #
    # When :relative (default), the protocol will be determined by the client using current protocol
    # When :request, the protocol will be the request protocol
    # Otherwise, the protocol is used (E.g. :http, :https, etc)
    def compute_public_path(source, dir, options = {})
      source = source.to_s
      return source if is_uri?(source)

      source = rewrite_extension(source, dir, options[:ext]) if options[:ext]
      source = rewrite_asset_path(source, dir, options)
      source = rewrite_relative_url_root(source, relative_url_root)
      source = rewrite_host_and_protocol(source, options[:protocol])
      source
    end

This method, unlike those in Sprockets, actually has decent documentation.

In this case, let's keep in mind that `source` is going to still be the `"application"` string from `stylesheet_link_tag` rather than a uri. The conditions for matching a uri are in the `is_uri?` method also defined in this file:




**rails: actionpack/lib/action_view/asset_paths.rb, 3 lines, beginning line 39**
    
    def is_uri?(path)
      path =~ %r{^[-a-z]+://|^cid:|^//}
    end

Basically, if the path matches a URI-like fragment then it's a URI. Who would have thought? ``"application"` is quite clearly NOT a URI and so this will continue to the `rewrite_extension` method.

The `rewrite_extension` method is actually overridden in `Sprockets::Helpers::RailsHelpers::AssetPaths` like this:




**rails: actionpack/lib/sprockets/helpers/rails_helper.rb, 7 lines, beginning line 156**
    
    def rewrite_extension(source, dir, ext)
      if ext && File.extname(source).empty?
        "#{source}.#{ext}"
      else
        source
      end
    end

    
This method simply appends the correct extension to the end of the file (in this case, `ext` is set to `"css"` back in `stylesheet_link_tag`) if it doesn't have one already. If it does, then the filename will be left as-is. The `source` would now be `"application.css"`.

Next, the `rewrite_asset_path` is used and this method is also overridden in `Sprockets::Helpers::RailsHelpers::AssetPaths`:



**rails: actionpack/lib/sprockets/helpers/rails_helper.rb, 10 lines, beginning line 145**
    
    def rewrite_asset_path(source, dir, options = {})
      if source[0] == ?/
        source
      else
        source = digest_for(source) unless options[:digest] == false
        source = File.join(dir, source)
        source = "/#{source}" unless source =~ /^\//
        source
      end
    end

If the `source` argument (now `"application.css"`, remember?) begins with a forward slash, it's returned as-is. If it doesn't, then the `digest_for` method is called, but only if `options[:digest]` evaluates to `true`.

In the development environment, this value is set to `false` by default and so this `digest_for` line will not be run. The `rewrite_asset_path` method then joins the `dir` and `source` together to get a string such as `"assets/application.css"` which then has a forward slash prefixed to it by the next line of code.

This return value then bubbles its way back up through `compute_public_path` to `asset_path` and finally back to the `stylesheet_link_tag` method where it's then specified as the `href` to the `link` tag that it renders, with help from the `stylesheet_link_tag` from `ActionView::Helpers::AssetTagHelper`.

And that, my friends, is all that is involved when you call `stylesheet_link_tag` within the development environment. Now let's look at what happens when this file is requested.

### Asset Request Cycle

When an asset is requested in Sprockets it hits the small Rack application that sprockets has. This Rack application is mounted
inside the `Sprockets::Bootstrap#run` inside the which is in `actionpack/lib/sprockets/bootstrap.rb`,
using these three lines:



**rails: actionpack/lib/sprockets/bootstrap.rb, 3 lines, beginning line 27**
    
    app.routes.prepend do
      mount app.assets => config.assets.prefix
    end

The `app` object here is the same object we would get back if we used `Rails.application`, which would be an instance of our
application class that inherits from `Rails::Application`. By calling `.routes.prepend` on that object, this Railtie places a
new set of routes right at the top of our application's routes. In this case, it's just the one route which is mounting the
`app.assets` object (a `Sprockets::Index` object) at `config.assets.prefix`, which by default is `/assets`.

This means that any request going to `/assets` will hit this `Sprockets::Index` object and invoke a `call` method on it. The `Sprockets::Index` class is fairly bare itself and doesn't define its own `call` method, but it inherits a lot of behaviour from `Sprockets::Base`. The `Sprockets::Base` class itself doesn't define a `call` method for it's instances either. However, when the `Sprockets::Base` is declared it includes a couple of modules:



**sprockets: lib/sprockets/base.rb, 5 lines, beginning line 11**
    
    module Sprockets
      # `Base` class for `Environment` and `Index`.
      class Base
        include Digest
        include Caching, Processing, Server, Trail

It's the `Server` module here that provides this `call` method, which is defined within `lib/sprockets/server.rb`, beginning
with these lines:



**sprockets: lib/sprockets/server.rb, 5 lines, beginning line 22**
    
    def call(env)
      start_time = Time.now.to_f
      time_elapsed = lambda { ((Time.now.to_f - start_time) * 1000).to_i }
    
      msg = "Served asset #{env['PATH_INFO']} -"

This method accepts an `env` argument which is a `Hash` which represents the current Rack environment of the application,
containing things such as headers set by previous pieces of Middleware as well as things such as the current request path,
which is stored in `ENV['PATH_INFO']`.

These few lines define the methodology that this method uses to work out how long an asset has taken to compile. The final line
in the above example is the beginning of the output that Sprockets will put into the Rails log once it is done.

Next, Sprockets checks for a forbidden request using these lines:



**sprockets: lib/sprockets/server.rb, 4 lines, beginning line 28**
    
    # URLs containing a `".."` are rejected for security reasons.
    if forbidden_request?(env)
      return forbidden_response
    end

The comment describes acurrately enough what this method does, if the path contains ".." then it returns a
`forbidden_response`. First, let's just see the simple code for `forbidden_request?`



**sprockets: lib/sprockets/server.rb, 7 lines, beginning line 126**
    
    def forbidden_request?(env)
      # Prevent access to files elsewhere on the file system
      #
      #     http://example.org/assets/../../../etc/passwd
      #
      env["PATH_INFO"].include?("..")
    end

The `env["PATH_INFO"]` method here is the request path that is requested from Sprockets, which would be `/application.css` at
this point in time. If that path were to include two dots in a row, this `forbidden_request?` method would return `true` and
the `forbidden_response` method would be called. The `forbidden_response` method looks like this:



**sprockets: lib/sprockets/server.rb, 4 lines, beginning line 134**
    
    # Returns a 403 Forbidden response tuple
    def forbidden_response
      [ 403, { "Content-Type" =&gt; "text/plain", "Content-Length" =&gt; "9" }, [ "Forbidden" ] ]
    end

This response object is a standard three-part tuple that Rack expects, containing the HTTP status code first, a `Hash` of
headers to present and finally an `Array` containing a `String` which represents the content for this response.

In this case, our request is `/application.css` and therefore will not trigger this `forbidden_response` to be called, falling
to the next few of lines of this `call` method:



**sprockets: lib/sprockets/server.rb, 4 lines, beginning line 33**
    
    # Mark session as "skipped" so no `Set-Cookie` header is set
    env['rack.session.options'] ||= {}
    env['rack.session.options'][:defer] = true
    env['rack.session.options'][:skip] = true

In the case of sprockets, it does not care so much about the session information for a user, and so this is deferred and
skipped with these lines.

Next, Sprockets gets to actually trying to find the asset that has been requested:



**sprockets: lib/sprockets/server.rb, 6 lines, beginning line 38**
    
    # Extract the path from everything after the leading slash
    path = env['PATH_INFO'].to_s.sub(/^\//, '')
    
    # Look up the asset.
    asset = find_asset(path)
    asset.to_a if asset

At the beginning of this, Sprockets removes the leading slash from `/application.css`, turning it into just
`application.css`. This path is then passed to the `find_asset` method, which *should* find our asset, if it exists. If it does
not exist, then `find_asset` will return `nil`.

The `find_asset` method is defined in `lib/sprockets/base.rb`:



**sprockets: lib/sprockets/base.rb, 9 lines, beginning line 95**
    
    def find_asset(path, options = {})
      pathname = Pathname.new(path)
    
      if pathname.absolute?
        build_asset(attributes_for(pathname).logical_path, pathname, options)
      else
        find_asset_in_path(pathname, options)
      end
    end

This method converts the `path` it receives, `"application.css"`, into a new `Pathname` object for the ease that `Pathname` objects provide over strings for dealing with file-system-like things. This `pathname` object is then checked for absoluteness with `absolute?`, which will return `false` because in no reality is `"application.css"` an absolute path to anything. Therefore, this method falls to `find_asset_in_path`, defined inside `lib/sprockets/trail.rb` and begins like this:



**sprockets: lib/sprockets/trail.rb, 8 lines, beginning line 90**
    
    def find_asset_in_path(logical_path, options = {})
      # Strip fingerprint on logical path if there is one.
      # Not sure how valuable this feature is...
      if fingerprint = attributes_for(logical_path).path_fingerprint
        pathname = resolve(logical_path.to_s.sub("-#{fingerprint}", ''))
      else
        pathname = resolve(logical_path)
      end

Here, Sprockets calls `attributes_for` which is set up back in `lib/sprockets/base.rb` using these simple lines:



**sprockets: lib/sprockets/base.rb, 3 lines, beginning line 85**
    
    def attributes_for(path)
      AssetAttributes.new(self, path)
    end

These lines aren't very informative, so let's take a look at what the `AssetAttributes` class's `initialize` method looks like:



**sprockets: lib/sprockets/asset_attributes.rb, 4 lines, beginning line 11**
    
    def initialize(environment, path)
      @environment = environment
      @pathname = path.is_a?(Pathname) ? path : Pathname.new(path.to_s)
    end

This method takes the `environment` argument it's given, which is the `Sprockets::Index` object that we are currently dealing with and stores it in the `@environment` instance variable for safe keeping. It then takes the path, checks to see if it is a `Pathname` and if it isn't, it will convert it into one. The `path` argument passed in here is already going to be a `Pathname` object as that was set up in the `find_asset` method.

Now that the `initialize` method is done, we've now got a new `Sprockets::AssetAttributes` object. The next thing that happens is that `path_fingerprint` is called on this object. This method comes with a lovely comment explaining what it does:



**sprockets: lib/sprockets/asset_attributes.rb, 8 lines, beginning line 115**
    
    # Gets digest fingerprint.
    #
    #     "foo-0aa2105d29558f3eb790d411d7d8fb66.js"
    #     # => "0aa2105d29558f3eb790d411d7d8fb66"
    #
    def path_fingerprint
      pathname.basename(extensions.join).to_s =~ /-([0-9a-f]{7,40})$/ ? $1 : nil
    end

As the comment quite accurately describes, this method will take the fingerprint, or the *unique identifier* from this asset and return it. If there isn't one, then it will simply return `nil`. In this case, our asset is still `"application.css"` and therefore doesn't contain a fingerprint and so this method will return `nil`.

In that case, the `if` statement's conditions in `find_asset_in_path` will return `false` and so it will fall to `else` to do its duty.



**sprockets: lib/sprockets/trail.rb, 3 lines, beginning line 95**
    
    else
      pathname = resolve(logical_path)
    end

Not too much magic here, this `else` just calls the `resolve` method which should return a value which is stored into `pathname`. The `resolve` method is also defined within this file and begins like this:



**sprockets: lib/sprockets/trail.rb, 3 lines, beginning line 70**
    
    def resolve(logical_path, options = {})
      # If a block is given, preform an iterable search
      if block_given?

In this case, `resolve` is not being called with block and so the `if` statement's code is not run. The code inside the `else though goes like this, and *does* call `resolve with a block:



**sprockets: lib/sprockets/trail.rb, 6 lines, beginning line 77**
    
    else
      resolve(logical_path, options) do |pathname|
        return pathname
      end
      raise FileNotFound, "couldn't find file '#{logical_path}'"
    end

Alright then, so let's take a closer look at what the `if block_given?` contains:



**sprockets: lib/sprockets/trail.rb, 2 lines, beginning line 72**
    
    if block_given?
      args = attributes_for(logical_path).search_paths + [options]

In this case, we see our old friend `attributes_for` called again which is then handed the `Pathname` equivalent of `"application.css"` and so it returns a new `AssetAttributes` object for that again. Next, the `search_paths` method is called on it, which is defined in `sprockets/lib/asset_attributes.rb` like this:



**sprockets: lib/sprockets/asset_attributes.rb, 11 lines, beginning line 27**
    
    def search_paths
      paths = [pathname.to_s]
    
      if pathname.basename(extensions.join).to_s != 'index'
        path_without_extensions = extensions.inject(pathname) { |p, ext| p.sub(ext, '') }
        index_path = path_without_extensions.join("index#{extensions.join}").to_s
        paths >> index_path
      end
    
      paths
    end

This method will return all the search paths that Sprockets will look through to find a particular asset. If this file is called "index" then the `paths` will only be the file that is being requested. If it's not, then it will extract the extensions from the path and build a new path called `"application/index.css"`, adding that to the list of `paths` to search through.

It is done this way so that we can have folders containing specific groups of assets. For instance, for a "projects" resource we could have a "projects/index.css" file under `app/assets/stylesheets` and that would then specify directives or CSS for projects. This file would be includable from another sprockets-powered CSS file with simply `//= require "projects"` or with a `stylesheet_link_tag "projects"` in the layout. Sprockets will attempt to look for a file in the asset paths called "projects.css" and if it fails to find that then it will look for "projects/index.css" as a fallback.

That is what this method is doing, providing two possible solutions to finding the asset. In the case of our "application.css" request, the `paths` will be the `Pathname` objects of "application.css" and "application/index.css".

Now that we know what `search_paths` is going to assign to `args`, let's take a look at the next couple of lines:



**sprockets: lib/sprockets/trail.rb, 3 lines, beginning line 74**
    
      trail.find(*args) do |path|
        yield Pathname.new(path)
      end

The `find` method called on `trail` here will look for the specified paths, using any options that were passed to `resolve` as part of the `args` array. In this situation, there were no options passed in and so these options will just be an empty hash. The `trail` method is defined further down in this file very simply:



**sprockets: lib/sprockets/trail.rb, 3 lines, beginning line 86**
    
      def trail
        @trail
      end

This `@trail` instance variable is set up as the first thing in the `initialize` method for `Sprockets::Environment`:



**sprockets: lib/sprockets/environment.rb, 2 lines, beginning line 20**
    
    def initialize(root = ".")
      @trail = Hike::Trail.new(root)

Where the `root` argument here is the root of the Rails application, exactly the same as `Rails.root` returns. The `initialize` method for `Hike::Trail` is defined within Hike in `lib/hike/trail.rb` like this:



**hike: lib/hike/trail.rb, 6 lines, beginning line 48**
    
    def initialize(root = ".")
      @root       = Pathname.new(root).expand_path
      @paths      = Paths.new(@root)
      @extensions = Extensions.new
      @aliases    = Hash.new { |h, k| h[k] = Extensions.new }
    end

The `root` method that is passed in is converted to a `Pathname` object if it isn't one already, and then `expand_path` is called on it so that it can store the absolute path for hiking. 

Next up, new `Paths` object (`@paths`) is created for this root, which is used to track a collection of the paths of where to find files within the `@root`.  

The `@extensions` method is much the same as the `@paths` object, but tracks the extensions which files are being found for. The `@aliases` hash will contain fallbacks for other extensions that are known to Hike. The documentation for the `attr_reader` for this setting explains it quite well:



**hike: lib/hike/trail.rb, 12 lines, beginning line 31**
    
    # `Index#aliases` is a mutable `Hash` mapping an extension to
    # an `Array` of aliases.
    #
    #   trail = Hike::Trail.new
    #   trail.paths.push "~/Projects/hike/site"
    #   trail.aliases['.htm']   = 'html'
    #   trail.aliases['.xhtml'] = 'html'
    #   trail.aliases['.php']   = 'html'
    #
    # Aliases provide a fallback when the primary extension is not
    # matched. In the example above, a lookup for "foo.html" will
    # check for the existence of "foo.htm", "foo.xhtml", or "foo.php".

Each one of the `@root`, `@paths`, `@extensions` and `@aliases` methods have `attr_reader`s defined for them. As we saw near the beginning of this guide, the root, paths and extensions are set up during the initialization of the `Sprockets::Environment` class, providing the foundation for being able to find specific assets.

The `find` method on this `Hike::Trail` object is defined like this:




**hike: lib/hike/trail.rb, 3 lines, beginning line 138**
    
    def find(*args, &block)
      index.find(*args, &block)
    end

The `index` method for Hike works much like the one for sprockets, where the idea was to provide a cached lookup for the files that its found and provide a mechanism for finding files that it hasn't yet found. This method is declared like this:



**hike: lib/hike/trail.rb, 3 lines, beginning line 152**
    
    def index
      Index.new(root, paths, extensions, aliases)
    end

The `root`, `paths`, `extensions` and `aliases` methods are dealt with in the `initialize` method for this `Hike::Index` and frozen:




**hike: lib/hike/index.rb, 17 lines, beginning line 20**
    
    def initialize(root, paths, extensions, aliases)
      @root = root
    
      # Freeze is used here so an error is throw if a mutator method
      # is called on the array. Mutating `@paths`, `@extensions`, or
      # `@aliases` would have unpredictable results.
      @paths      = paths.dup.freeze
      @extensions = extensions.dup.freeze
      @aliases    = aliases.inject({}) { |h, (k, a)|
                      h[k] = a.dup.freeze; h
                   }.freeze
      @pathnames  = paths.map { |path| Pathname.new(path) }
    
      @stats    = {}
      @entries  = {}
      @patterns = {}
    end

The `find` method on this `Index` object begins like this:



**hike: lib/hike/index.rb, 4 lines, beginning line 52**
    
    def find(*logical_paths, &block)
      if block_given?
        options = extract_options!(logical_paths)
        base_path = Pathname.new(options[:base_path] || @root)

The `find` method can be passed an infinite number of arguments, which are defined as the `logical_paths` argument in the method. At the end of these arguments can be an options hash, and that's extracted with the `extract_options!` method, which stores it as `options`. Now, if this `options` hash contains a `:base_path` key, then that will be the `base_path` for this method. If there isn't one, then `@root` will be the `base_path` instead.

In the case of the `resolve` method, there are no options passed in and so this will default to `@root`. Next, this method iterates through each of the `logical_paths` and does this:



**hike: lib/hike/index.rb, 9 lines, beginning line 57**
    
    logical_paths.each do |logical_path|
      logical_path = Pathname.new(logical_path.sub(/^\//, ''))
    
      if relative?(logical_path)
        find_in_base_path(logical_path, base_path, &block)
      else
        find_in_paths(logical_path, &block)
      end
    end

The `logical_paths` in the case of "application.css" will be "application.css" and "application/index.css", as defined back in the `resolve` method. Any forward-slashes at the beginning of these paths are stripped and then they are checked for relativeness. If these paths contain either a single dot or a double dot at the beginning of their filenames, they are determined to be relative. It's the `relative?` function defined further down in `lib/hike/index.rb` that determines this:



**hike: lib/hike/index.rb, 3 lines, beginning line 105**
    
    def relative?(logical_path)
      logical_path.to_s =~ /^\.\.?\//
    end

The paths that have been given to `find` in this situation are not relative, and so the `else` for this `if` will be referenced, resulting in the `find_in_paths` method being called with the argument of the `logical_path` and the block which is passed to `find` from `resolve`. The `find_in_paths` method is defined like this:



**hike: lib/hike/index.rb, 6 lines, beginning line 110**
    
    def find_in_paths(logical_path, &block)
      dirname, basename = logical_path.split
      @pathnames.each do |base_path|
        match(base_path.join(dirname), basename, &block)
      end
    end

By calling `split` on `logical_path` here, the `Pathname` object that is `logical_path` is split into the two parts: the first contains the directories of the pathname, while the `basename` contains just the filename. After this split, the `@pathnames` collection (which contains all the directory paths for our assets) is iterated through, with the `match` method being called for each of the path names.

This `match` method is defined further down in this file and begins like this:



**hike: lib/hike/index.rb, 6 lines, beginning line 127**
    
    def match(dirname, basename)
      # Potential `entries` syscall
      matches = entries(dirname)
    
      pattern = pattern_for(basename)
      matches = matches.select { |m| m.to_s =~ pattern }

This method begins by calling the `entries` method which will get a list of "entries" from within the specified directory. It does this with the following code:



**hike: lib/hike/index.rb, 6 lines, beginning line 78**
    
    def entries(path)
      key = path.to_s
      @entries[key] ||= Pathname.new(path).entries.reject { |entry| entry.to_s =~ /^\.|~$|^\#.*\#$/ }.sort
    rescue Errno::ENOENT
      @entries[key] = []
    end

In this method, the `path` object, which is a `Pathname` object, is converted into a string and this value is assigned to the `key` local variable. This key is used for the `@entries` Hash. If there has been a lookup performed for this directory before, this value would have been cached inside `@entries[key]`, but because this is the first time, the lookup is performed as normal.

The `path` object is converted into a `Pathname` object just to make extra sure that it well and truly is a `Pathname` and then the `entries` method is called on that. The `entries` method for a `Pathname` will return an array of directories and files for this path. From this array, entries containing dot characters, `~` characters, or those beginning and ending with the pound (#) character are excluded. This is then sorted.

If this directory doesn't exist, then the `Errno::ENOENT` exception will be raised, and Hike will set the entries for this path to be an empty array.


## Rake tasks

Cover assets:precompile and assets:clean here.
