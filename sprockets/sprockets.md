Yesterday's post and twitter bitching caught the eye of our <a href='http://twitter.com/dhh'>fearless leader</a> who basically claimed <a href='https://twitter.com/#!/dhh/status/81987522766450688'>that I've not made documentation patches recently</a>. I responded with a small reminder that I've done <a href='https://twitter.com/ryanbigg/status/81988004947828736'>some documentation work</a> and went a step further and begun an <a href='http://ryanbigg.com/guides/asset_pipeline.html'>Asset Pipeline Guide</a> because I could. I could have pulled the whole "Don't you know who I am?!!" faux-lebrity deal, but I thought I would be humble. Append "for a change" to the end of the previous sentence, if you wish.

That was incredibly fun. We should do it again some time. Have your people call my people, we'll do lunch.

Before all that went down, I created a short (by my standards, anyway) <a href='https://gist.github.com/1032696'>Gist about how the `Sprockets::Railtie` class is currently set up in Rails</a>. This little Gist begun as short note taking for myself and I thought that maybe other people would find the information helpful, so I formatted it all pretty like.

After the *battle of the egos* took place, I delved a little deeper into the Sprockets rabbit hole, got defeated by some gnarly code and thought "fuck it dude, let's go <s>bowling</s> to sleep". I awoke this morning and delved a little deeper into exactly how all of this magic happens. So here goes.

Hopefully with this information, somebody else besides Josh Peek, Sam Stephenson, Yehuda Katz and (partially) myself can begin to understand how Sprockets works.

### Sprockets Asset Helpers

Within Rails 3.1, the behaviour of `javascript_include_tag` and `stylesheet_link_tag` are modified by the `actionpack/lib/sprockets/rails_helper.rb` file which is required by `actionpack/lib/sprockets/railtie.rb`, which itself is required by `actionpack/lib/action_controller/railtie.rb` and so on, and so forth.

The `Sprockets::Helpers::RailsHelper` is included into ActionView through the process described in my earlier [Sprockets Railtie Setup](https://gist.github.com/1032696) internals doc. Once this is included, it will override the `stylesheet_link_tag` and `javascript_include_tag` methods originally provided by Rails itself. Of course, if assets were disabled (`Rails.application.config.assets.enabled = false`) then the original Rails methods would be used and JavaScript assets would then exist in `public/javascripts`, not `app/assets/javascripts`. Let's just assume that you're using Sprockets.

Let's take a look at the `stylesheet_link_tag` method from `Sprockets::Helpers::RailsHelper`. The `javascript_include_tag` method is very similar so if you want to know how that works, just replace `stylesheet_link_tag` with `javascript_include_tag` using your *mind powers* and I'm sure you can get the gist of it.

#### What `stylesheet_link_tag` / `javascript_include_tag` does

This method begins like this: 

<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='42'>
def stylesheet_link_tag(*sources)
  options = sources.extract_options!
  debug = options.key?(:debug) ? options.delete(:debug) : debug_assets?
  body  = options.key?(:body)  ? options.delete(:body)  : false
</div>

The first argument for `stylesheet_link_tag` is a splatted `sources` which means that this method can take a list of stylesheets or manifest files and will process each of them. The method also takes some `options`, which are extracted out on the first line of this method using `extract_options!`. The two currently supported are `debug` and `body`.

The `debug` option will expand any manifest file into its contained parts and render each file individually. For example, in a project I have here, this line:

    <%= stylesheet_link_tag "application" %>

When a request is made to this page that uses this layout that renders this file, it will be printed as a single line:
    
    <link href="/assets/application.css" media="screen" rel="stylesheet" type="text/css" /> 

Even though the file it's pointing to contains *directives* to Sprockets to include everything in `app/assets/stylesheets`:

    *= require_self
    *= require_tree .

What sprockets is doing here is reading this manifest file and compiling all the CSS assets specified into one big fuck-off file and serving just that instead of the \*counts\* 13 CSS files I've got in that directory.

This helper then iterates through the list of sources specified and first dives in to checking the `debug` option. If `debug` is set to true for this though, either through `options[:debug]` being passed or by `debug_assets?` evaluating to `true`, this will happen:

<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='47'>
sources.collect do |source|
  if debug && asset = asset_paths.asset_for(source, 'css')
    asset.to_a.map { |dep|
      stylesheet_link_tag(dep, :debug => false, :body => true)
    }.join("\n").html_safe
</div>
      
The `debug_assets?` method is defined as a private method further down in this file:

<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='71'>
private
  def debug_assets?
    params[:debug_assets] == '1' ||
      params[:debug_assets] == 'true'
  rescue NoMethodError
    false
  end
</div>

If `?debug_assets=1` or `?debug_assets=true` is appended to the page (or the parameter is set some other way) then the assets will be "debugged". There *may* be a case where `params` doesn't exist, and so this method rescues a potential `NoMethodError` that could be thrown. Although I can't imagine a situation in Rails where that would ever be the case.

Back to the code within `stylesheet_link_tag`, this snippet will get all the assets specified in the manifest file, iterate over each of them and render a `stylesheet_link_tag` for each of them, ensuring that `:debug` is set to false for them. 

It's important to note here that the CSS files that the original `app/assets/stylesheets/application.css` points to can each be their own manifest file, and so on and so forth.

If the `debug` option isn't specified and `debug_assets?` evaluates to `false` then the `else` for this `if` will be executed:

<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='52'>
else
  tag_options = {
    'rel'   => "stylesheet",
    'type'  => "text/css",
    'media' => "screen",
    'href'  => asset_path(source, 'css', body, :request)
  }.merge(options.stringify_keys)

  tag 'link', tag_options
end
</div>

This calls the `asset_path` method which is defined like this:

<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='65'>
def asset_path(source, default_ext = nil, body = false, protocol = nil)
  source = source.logical_path if source.respond_to?(:logical_path)
  path = asset_paths.compute_public_path(source, 'assets', default_ext, true, protocol)
  body ? "#{path}?body=1" : path
end
</div>

(WIP: I don't know what `logical_path` is for, so let's skip over that for now. In my testing, `source` has always been a `String` object).

This method then calls out to `asset_paths` which is defined at the top of this file:

<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='9'>
def asset_paths
  @asset_paths ||= begin
    config     = self.config if respond_to?(:config)
    config   ||= Rails.application.config
    controller = self.controller if respond_to?(:controller)
    paths = RailsHelper::AssetPaths.new(config, controller)
    paths.asset_environment = asset_environment
    paths.asset_prefix      = asset_prefix
    paths
  end
end
</div>

This method (obviously) initializes a new instance of the `RailsHelper::AssetPaths` class defined later in this file, passing through the `config` and `controller` objects of the current content, which would be the same `self.config` and `self.controller` available within a view.

This `RailsHelper::AssetPaths` inherits behaviour from `ActionView::AssetPaths`, which is responsible for resolving the paths to the assets for vanilla Rails. The `RailsHelper::AssetPaths` overrides some of the methods defined within its superclass, though. 

The `asset_environment` method is defined also in this file:

<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='92'>
def asset_environment
  Rails.application.assets
end
</div>

The `assets` method called inside the `asset_environment` method returns a `Sprockets::Index` instance, which we'll get to later.

The `asset_prefix` is defined just above this:
 
<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='85'>
def asset_prefix
  Rails.application.config.assets.prefix
end
</div>

The next method is `compute_public_path` which is called on this new `RailsHelper::AssetPaths` instance. This is defined simply:


<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='99'>
def compute_public_path(source, dir, ext=nil, include_host=true, protocol=nil)
  super(source, asset_prefix, ext, include_host, protocol)
end
</div>

This calls back to the `compute_public_path` within `ActionView::AssetsPaths` (`actionpack/lib/action_view/asset_paths.rb`) which is defined like this:


<div class="example" data-repo='rails' data-file='actionpack/lib/action_view/asset_paths.rb' data-start='14'>
# Add the extension +ext+ if not present. Return full or scheme-relative URLs otherwise untouched.
# Prefix with &lt;tt&gt;/dir/&lt;/tt&gt; if lacking a leading +/+. Account for relative URL
# roots. Rewrite the asset path for cache-busting asset ids. Include
# asset host, if configured, with the correct request protocol.
#
# When include_host is true and the asset host does not specify the protocol
# the protocol parameter specifies how the protocol will be added.
# When :relative (default), the protocol will be determined by the client using current protocol
# When :request, the protocol will be the request protocol
# Otherwise, the protocol is used (E.g. :http, :https, etc)
def compute_public_path(source, dir, ext = nil, include_host = true, protocol = nil)
  source = source.to_s
  return source if is_uri?(source)

  source = rewrite_extension(source, dir, ext) if ext
  source = rewrite_asset_path(source, dir)
  source = rewrite_relative_url_root(source, relative_url_root) if has_request?
  source = rewrite_host_and_protocol(source, protocol) if include_host
  source
end
</div>

This method, unlike those in Sprockets, actually has decent documentation.

In this case, let's keep in mind that `source` is going to still be the `"application"` string from `stylesheet_link_tag` rather than a uri. The conditions for matching a uri are in the `is_uri?` method also defined in this file:


<div class="example" data-repo='rails' data-file='actionpack/lib/action_view/asset_paths.rb' data-start='41'>
def is_uri?(path)
  path =~ %r{^[-a-z]+://|^cid:|^//}
end
</div>

Basically, if the path matches a URI-like fragment then it's a URI. Who would have thought? ``"application"` is quite clearly NOT a URI and so this will continue to the `rewrite_extension` method.

The `rewrite_extension` method is actually overridden in `Sprockets::Helpers::RailsHelpers::AssetPaths` like this:


<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='123'>
def rewrite_extension(source, dir, ext)
  if ext && File.extname(source).empty?
    "#{source}.#{ext}"
  else
    source
  end
end
</div>
    
This method simply appends the correct extension to the end of the file (in this case, `ext` is set to `"css"` back in `stylesheet_link_tag`) if it doesn't have one already. If it does, then the filename will be left as-is. The `source` would now be `"application.css"`.

Next, the `rewrite_asset_path` is used and this method is also overridden in `Sprockets::Helpers::RailsHelpers::AssetPaths`:

<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='115'>
def rewrite_asset_path(source, dir)
  if source[0] == ?/
    source
  else
    asset_environment.path(source, performing_caching?, dir)
  end
end
</div>

If the `source` argument (now `"application.css"`, remember?) begins with a forward slash, it's returned as-is. If not, then the `assets` method is called and then the `path` method is called on that. First up though, `performing_caching?` is one of the arguments of this method, and is defined like this:

<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='132'>
def performing_caching?
  config.action_controller.present? ? config.action_controller.perform_caching : config.perform_caching
end
</div>

We saw that the `asset_environment` method earlier was defined like this:

<div class="example" data-repo='rails' data-file='actionpack/lib/sprockets/helpers/rails_helper.rb' data-start='92'>
def asset_environment
  Rails.application.assets
end
</div>

It returns the `Sprockets::Index` object and finally does something useful with it, calling `path` on it.

The `path` method defined on this object is defined within sprockets itself at `like this: 

<div class="example" data-repo='sprockets' data-file='lib/sprockets/server.rb' data-start='89'>
def path(logical_path, fingerprint = true, prefix = nil)
  if fingerprint && asset = find_asset(logical_path.to_s.sub(/^\//, ''))
    url = attributes_for(logical_path).path_with_fingerprint(asset.digest)
  else
    url = logical_path
  end

  url = File.join(prefix, url) if prefix
  url = "/#{url}" unless url =~ /^\//

  url
end
</div>

If the file contains a "fingerprint" (an MD5 hash which is unique for this "version" of this file) then it will return a path such as `application-13e6dd6f2d0d01b7203c43a264d6c9ef.css`. We are operating in the development environment for now, and so this will simply return the `application.css` filename we've come to know and love.

The final three lines of this method will append the `assets` prefix which has been passed in, coming from the `Rails.application.config.assets.prefix`, so that our path now becomes `assets/application.css` and this will also prefix a forward-slash to this path (unless it has one already), turning it into `/assets/application.css`. The third and final line simply returns the `url`, just in case the `unless` does nothing.

This return value then bubbles up through `rewrite_asset_path` to `compute_public_path` to `asset_path` and finally back to the `stylesheet_link_tag` method where it's then specified as the `href` to the `link` tag that it renders.

And that, my friends, is all that is involved when you call `stylesheet_link_tag` within the development environment. Now let's look at what happens when we do the same thing, but in production.

#### Later, in production

In production, things work very similarly to the process just described except for (obviously) some key differences. In the production environment, `performing_caching?` will return `true` and therefore the `path` method in `Sprockets::EnvironmentIndex` will receive it's `fingerprint` argument as `true`, rather than `false`.

This means that this code in `path` inside `Sprockets::Environment` will be called:

<div class="example" data-repo='sprockets' data-file='lib/sprockets/server.rb' data-start='90'>
if fingerprint && asset = find_asset(logical_path.to_s.sub(/^\//, ''))
  url = attributes_for(logical_path).path_with_fingerprint(asset.digest)
else
</div>

In this case, `fingerprint` is going to be `true` so that part of the `if` will run. But what does `find_asset` do? Well, it takes the `logical_path` (in this case, just `application.css`, as the conversion to `/assets/application.css` hasn't yet been done), sans any single forward slash at the beginning. 

The `find_asset` method is defined in `sprockets/lib/sprockets/environment.rb`:

<div class="example" data-repo='sprockets' data-file='lib/sprockets/environment.rb' data-start='54'>
def find_asset(path, options = {})
  cache_asset(path) { super }
end
</div>

This simply calls the `cache_asset` method and passes in the result of
`super`, which is another `find_asset` method. To understand
`cache_asset` we must first understand this other `find_asset` method. This one is defined
within `sprockets/lib/sprockets/base.rb`:

<div class="example" data-repo='sprockets' data-file='lib/sprockets/base.rb' data-start='61'>
def find_asset(path, options = {})
  pathname = Pathname.new(path)

  if pathname.absolute?
    build_asset(detect_logical_path(path).to_s, pathname, options)
  else
    find_asset_in_static_root(pathname) ||
      find_asset_in_path(pathname, options)
  end
end
</div>

This method creates a new `Pathname` object out of the `path` that we
are given and checks to see if that path is `absolute?`. In this case,
`application.css` is not going to be absolute path and so the code for
the `if` is not run, but instead we fall to the `else` and the
`find_asset_in_static_root` method in it, which is passed this new
`Pathname` object. 

This method is defined in
`sprockets/lib/sprockets/static_compilation.rb` and begins like this:

<div class="example" data-repo='sprockets' data-file='lib/sprockets/static_compilation.rb' data-start='46'>
def find_asset_in_static_root(logical_path)
  return unless static_root
</div>

This method first calls the `static_root` method, which is pretty boring:

<div class="example" data-repo='sprockets' data-file='lib/sprockets/static_compilation.rb' data-start='8'>
def static_root
  @static_root
end
</div>

This instance variable is defined using the `static_root=` method
defined underneath its getter brother:

<div class="example" data-repo='sprockets' data-file='lib/sprockets/static_compilation.rb' data-start='12'>
def static_root=(root)
  expire_index!
  @static_root = root ? Pathname.new(root) : nil
end
</div>

This method is called inside an old friend, the `actionpack/lib/sprockets/railtie.rb`
file, which is responsible for creating the Railtie within Rails itself
that is used to load Sprockets. The call to `static_root=` is within the
"sprockets.environment" initializer, and is called like this:

<div class="example" data-repo='rails'
data-file='actionpack/lib/sprockets/railtie.rb' data-start='20'>
app.assets = Sprockets::Environment.new(app.root.to_s) do |env|
  env.static_root = File.join(app.root.join('public'), config.assets.prefix)
</div>

In this situation, we can see a new `Sprockets::Environment` object is
initialized and that initialization is given a block where the
`static_root=` method is called, a `File.join`'d path of
`#{app.root}/public/#{config.assets.prefix}` is given, which evaluates
to `#{Rails.root}/public/assets` in default installations.

So that's how `@static_root` is set, and so armed with that knowledge we
know that the `static_root` method call in `find_asset_in_static_root`
is going to return a value, and therefore go further. The next couple of
lines of this
method look like this:


<div class="example" data-repo='sprockets' data-file='lib/sprockets/static_compilation.rb' data-start='49'>
  pathname   = Pathname.new(static_root.join(logical_path))
  attributes = attributes_for(pathname)

  entries = entries(pathname.dirname)

  if entries.empty?
    return nil
  end
</div>

The method defines a new `pathname` object, joining the `static_root`
and the `logical_path` together. The `logical_path` in this instance is
the `Pathname` object consisting just of `application.css` at this
point, and joining them together results in
`#{Rails.root}/public/assets/application.css`.

This code then calls out to `attributes_for`, defined in
`lib/sprockets/base.rb`:

<div class="example" data-repo='sprockets' data-file='lib/sprockets/base.rb' data-start='53'>
def attributes_for(path)
  AssetAttributes.new(self, path)
end
</div>

This `AssetAttributes` class is defined inside
`lib/sprockets/asset_attributes.rb`, and it's `initialize` method is
defined like this:

<div class="example" data-repo='sprockets' data-file='lib/sprockets/asset_attributes.rb' data-start='7'>
def initialize(environment, path)
  @environment = environment
  @pathname = path.is_a?(Pathname) ? path : Pathname.new(path.to_s)
end
</div>

# Here be dragons

** I am currently in the process of re-working this document using
[http://github.com/radar/muse](muse). Please excuse me while I move the
furniture about.**
This `@cache` variable method is set up in the `expire_index!` method which actually serves two purposes: one is to initialize this cache when the `initialize` method for `Sprockets::Environment` is called. This happened way back when the `Sprockets::Railtie`'s `after_initialize` hook ran). The second is to clear this cache.

The moment, our `@cache` variable is going to be just an empty hash, and so the first `if` in this method will return nothing. The `asset` variable therefore won't be set, and so it will fall to the `else` which just returns `nil`

So that clears the `if` in `find_asset`, so then it goes to the `elsif` which, as a reminder, is defined like this:

    elsif asset = index.find_asset(logical_path, options.merge(:_environment => self))
      @cache[logical_path.to_s] = asset
      asset.to_a.each { |a| @cache[a.pathname.to_s] = a }
      asset
    end

This then falls down to the `index` (it's a `Sprockets::EnvironmentIndex` object, remember?) object, and the `find_asset` path defined on it. This is a *different* `find_asset` to the one that we saw before. That one was defined for `Sprockets::Environment` objects, where as this one is for a `Sprockets::EnvironmentIndex` object. This method is defined in `sprockets/lib/environment_index.rb` like this:

    def find_asset(path, options = {})
      options[:_index] ||= self

      pathname = Pathname.new(path)

      if pathname.absolute?
        build_asset(detect_logical_path(path).to_s, pathname, options)
      else
        logical_path = path.to_s.sub(/^\//, '')

        if @assets.key?(logical_path)
          @assets[logical_path]
        else
          @assets[logical_path] = find_asset_in_static_root(pathname) ||
            find_asset_in_path(pathname, options)
        end
      end
    end

This begins by removing any slash at the beginning of the path, but ours doesn't have one and so it will be left as is. The `@assets` variable is set up in the `initialize` method of `Sprockets::EnvironmentIndex`, and is just an empty `Hash` object at this stage. This means that this `@assets` hash would not contain the key of `"application.css"` at this point, and so it will go to the `else` for `@assets.key?(logical_path)`. 

Inside this `else`, Sprockets sets that `@assets[logical_path]` variable so that it doesn't have to find it again. To find that particular asset though, it first looks in a static root using `find_asset_in_static_root` and if it can't find one there then looks for it using `find_asset_in_path`.

Let's see what `find_asset_in_static_root` does first. This method is actually defined in `sprockets/lib/static_compliation.rb` and begins with these two lines:

    def find_asset_in_static_root(logical_path)
      return unless static_root

If `static_root` isn't set then this method will return nothing. So is this set? The method is defined at the top of `Sprockets::StaticCompilation` like this:

    def static_root
      @static_root
    end

But where is this `@static_root` variable set? If we look just underneath this `static_root` definition there's a `static_root=` definition which cleans the index and sets this variable:

    def static_root=(root)
      expire_index!
      @static_root = root
    end

This `static_root=` method is called when `Sprockets::EnvironmentIndex` is initialized, using this line:

      @static_root = static_root ? Pathname.new(static_root) : nil

The `EnvironmentIndex` object was initialized earlier when the `index` method was called on the `Sprockets::Environment` object. It does this:

    def index
      EnvironmentIndex.new(self, @trail, @static_root)
    end

This `@static_root` variable is set up when the `after_initialize` hook sets up the `Sprockets::Environment` object, in `Sprockets::Railtie` using this line:

    env.static_root = File.join(app.root.join("public"), assets.prefix)

The `assets` object here is the `Rails.application.config.assets` object set up in `railties/lib/rails/application/configuration.rb`, with the `prefix` method on it returning simply `/assets`. This means that the `env.static_root` will result in a path that points at the `public/assets` directory within the application.

This means that the `static_root` method back in `find_asset_in_static_root` is actually going to return a value and so the method will continue past this point. The next two lines in this method are these:

    pathname   = Pathname.new(static_root.join(logical_path))
    attributes = attributes_for(pathname)
 
The `logical_path` is still going to be `"application.css"`, and in this case it's going to be appended to the end of `static_path`, making the output something like `[Rails.root]/public/assets/application.css` and turning that into a `Pathname` object.

Next, the `attributes_for` method is called on this new `Pathname` object. This method is defined like this:

    def attributes_for(path)
      AssetAttributes.new(self, path)
    end

The `AssetAttributes` class is actually `Sprockets::AssetAttributes`. This class serves the purpose of providing several helper methods, some of them which we'll see in just a bit, for the assets of this application. The `initialize` method for this class is defined like this:

    def initialize(environment, path)
      @environment = environment
      @pathname = path.is_a?(Pathname) ? path : Pathname.new(path.to_s)
    end


The `environment` passed in is the `Sprockets::Environment` object we've been dealing with for a while now, and the `path` is the newly-initialized `Pathname` object set up just before `attributes_for` is called. No particularly big bit of magic going on here. Keep this little portion in mind for later on when this code is actually used.

The next thing this `find_asset_in_static_root` method does is check the directory supposedly containing the assets for any entries by using this code:

    entries = entries(pathname.dirname)

    if entries.empty?
      return nil
    end

The `entries` method is defined like this:

    def entries(pathname)
      @entries[pathname.to_s] ||= pathname.entries.reject { |entry| entry.to_s =~ /^\.\.?$/ }
    rescue Errno::ENOENT
      @entries[pathname.to_s] = []
    end

The little bonus thing here is that it caches the entries of a directory so that it doesn't have to look them up. The little `reject` call on the end of things will reject the `.` and `..` entries that would normally appear on an entries listing of this directory. If the directory can't be found (meaning an `Errno::ENOENT` exception is raised) then the cache for this directory is just set to an empty array.

Obviously, if there's no entries in this directory then `find_asset_in_static_root` will return `nil`. In this case, there are no files and therefore this method will indeed return `nil`, marking the end of `find_asset_in_static_root`.

Now back in the `find_asset` method, it will next try the `find_asset_in_path` method. This method is called like this:

    find_asset_in_path(pathname, options)

This method is defined in `Sprockets::EnvironmentIndex` and begins like this:

    def find_asset_in_path(logical_path, options = {})
      if fingerprint = path_fingerprint(logical_path)
        pathname = resolve(logical_path.to_s.sub("-#{fingerprint}", ''))
      else
        pathname = resolve(logical_path)
      end
      
The `path_fingerprint` method is defined inside `Sprockets::StaticCompilation` like this:

    def path_fingerprint(path)
      pathname = Pathname.new(path)
      extensions = pathname.basename.to_s.scan(/\.[^.]+/).join
      pathname.basename(extensions).to_s =~ /-([0-9a-f]{7,40})$/ ? $1 : nil
    end

This method takes an argument called `path` which is still just `"application.css"` at this point. From this specified path it attempts to grab a hexdigest at the end of this file, something like `"0abf44c386f64e72197c68d2f0aea31f"`, but if there isn't one it will return `nil`. Because `"applicaiton.css"` doesn't contain this hexdigest suffix, it will fall to the `else` in `find_asset_in_path` which calls the `resolve` method.

Methods called `resolve` are defined in several spots in Sprockets, but this one is from `Sprockets::EnvironmentIndex` which contains this code:

    def resolve(logical_path, options = {})
      if block_given?
        @trail.find(logical_path.to_s, logical_index_path(logical_path), options) do |path|
          yield Pathname.new(path)
        end
      else
        resolve(logical_path, options) do |pathname|
          return pathname
        end
        raise FileNotFound, "couldn't find file '#{logical_path}'"
      end
    end

In the first case, the `resolve` method is not passed a block and therefore it calls itself passing back through the `logical_path` and `options` it received, as well as a block. Now this goes back to the top of the method where the `if block_given?` statement evaluates to `true` and `@trail.find` is called.

This `@trail` variable is set up when the `Sprockets::Environment` object is initialized with this line:

    @trail = Hike::Trail.new(root)

The `Hike::Trail` class comes from the `hike` gem which `sprockets` depends on. The `root` passed in to this method is `Rails.application.root`. The `initialize` method in `Hike::Trail` is defined like this:

    def initialize(root = ".")
      @root       = Pathname.new(root).expand_path
      @paths      = Paths.new(@root)
      @extensions = Extensions.new
    end

While the `find` method is defined this way:

    def find(*args, &block)
      index.find(*args, &block)
    end

The `index` method referenced here is defined in Hike also:

    def index
      Index.new(root, paths, extensions)
    end
