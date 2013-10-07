---
layout: default
title: Gems with Extensions
previous: /make-your-own-gem
next: /name-your-gem
alias: /c-extensions
---

Many gems use extensions to wrap libraries that are written in C with a ruby
wrapper.  Examples include [nokogiri](https://rubygems.org/gems/nokogiri) which
wraps [libxml2 and libxslt](http://www.xmlsoft.org),
[pg](https://rubygems.org/gems/pg) which is an interface to the [PostgreSQL
database](http://www.postgresql.org) and the
[mysql](https://rubygems.org/gems/mysql) and
[mysql2](https://rubygems.org/gems/mysql) gems which provide an interface to
the [MySQL database](http://www.mysql.com).

Creating a gem that uses an extension involves several steps.  This guide will
focus on what you should put in your gem specification to make this as easy and
maintainable as possible.  The extension in this guide will wrap `malloc()` and
`free()` from the C standard library.

Gem layout
----------

Every gem should start with a Rakefile which contains the tasks needed by
developers to work on the gem.  The files for the extension should go in the
`ext/` directory in a directory matching the extension's name.  For this
example we'll use "my_malloc" for the name.

Some extensions will be partially written in C and partially written in ruby.
If you are going to support multiple languages, such as C and Java extensions,
you should put the C-specific ruby files under the `ext/` directory as well in a
`lib/` directory.

    Rakefile
    ext/my_malloc/extconf.rb               # extension configuration
    ext/my_malloc/my_malloc.c              # extension source
    lib/my_malloc.rb                       # generic features

When the extension is built the files in `ext/my_malloc/lib/` will be installed
into the `lib/` directory for you.

extconf.rb
----------

The extconf.rb configures a Makefile that will build your extension based.  The
extconf.rb must check for the necessary functions, macros and shared libraries
your extension depends upon.  The extconf.rb must exit with an error if any of
these are missing.

Here is an extconf.rb that checks for `malloc()` and `free()` and creates a
Makefile that will install the built extension at `lib/my_malloc/my_malloc.so`:

    require "mkmf"

    abort "missing malloc()" unless have_func "malloc"
    abort "missing free()"   unless have_func "free"

    create_makefile "my_malloc/my_malloc"

See the [mkmf documentation][mkmf.rb] and [README.EXT][README.EXT] for further
information about creating an extconf.rb and for documentation on these
methods.

C Extension
-----------

The C extension that wraps `malloc()` and `free()` goes in
`ext/my_malloc/my_malloc.c`.  Here's the listing:

    #include <ruby.h>

    struct my_malloc {
	size_t size;
	void *ptr;
    };

    static void
    my_malloc_free(void *p) {
	struct my_malloc *ptr = p;

	if (ptr->size > 0)
	    free(ptr->ptr);
    }

    static VALUE
    my_malloc_alloc(VALUE klass) {
	VALUE obj;
	struct my_malloc *ptr;

	obj = Data_Make_Struct(klass, struct my_malloc, NULL, my_malloc_free, ptr);

	ptr->size = 0;
	ptr->ptr  = NULL;

	return obj;
    }

    static VALUE
    my_malloc_init(VALUE self, VALUE size) {
	struct my_malloc *ptr;
	size_t requested = NUM2SIZET(size);

	if (0 == requested)
	    rb_raise(rb_eArgError, "unable to allocate 0 bytes");

	Data_Get_Struct(self, struct my_malloc, ptr);

	ptr->ptr = malloc(requested);

	if (NULL == ptr->ptr)
	    rb_raise(rb_eNoMemError, "unable to allocate %ld bytes", requested);

	ptr->size = requested;

	return self;
    }

    static VALUE
    my_malloc_release(VALUE self) {
	struct my_malloc *ptr;

	Data_Get_Struct(self, struct my_malloc, ptr);

	if (0 == ptr->size)
	    return self;

	ptr->size = 0;
	free(ptr->ptr);

	return self;
    }

    void
    Init_my_malloc(void) {
	VALUE cMyMalloc;

	cMyMalloc = rb_const_get(rb_cObject, rb_intern("MyMalloc"));

	rb_define_alloc_func(cMyMalloc, my_malloc_alloc);
	rb_define_method(cMyMalloc, "initialize", my_malloc_init, 1);
	rb_define_method(cMyMalloc, "free", my_malloc_release, 0);
    }

This extension is simple with just a few parts:

* `struct my_malloc` to hold the allocated memory
* `my_malloc_free()` to free the allocated memory after garbage collection
* `my_malloc_alloc()` to create the ruby wrapper object
* `my_malloc_init()` to allocate memory from ruby
* `my_malloc_release()` to free memory from ruby
* `Init_my_malloc()` to register the functions in the `MyMalloc` class.

You can test building the extension as follows:

    $ cd ext/my_malloc
    $ ruby extconf.rb
    checking for malloc()... yes
    checking for free()... yes
    creating Makefile
    $ make
    compiling my_malloc.c
    linking shared-object my_malloc.bundle
    $ cd ../..
    $ ruby -Ilib:ext -r my_malloc -e "p MyMalloc.new(5).free"
    #<MyMalloc:0x007fed838addb0>

But this will get tedious after a while.  Let's automate it!

rake-compiler
-------------

[rake-compiler][rake-compiler] is a set of rake
tasks for automating extension building.  rake-compiler can be used with C or
Java extensions in the same project (nokogiri uses it this way).

Adding rake-compiler is very simple:

    require "rake/extensiontask"

    Rake::ExtensionTask.new "my_malloc" do |ext|
      ext.lib_dir = "lib/my_malloc"
    end

Now you can build the extension with `rake compile` and hook the compile task
into other tasks (such as tests).

Setting `lib_dir` places the shared library in `lib/my_malloc/my_malloc.so` (or
`.bundle` or `.dll`).  This allows the top-level file for the gem to be a ruby
file.  This allows you to write the parts that are best suited to ruby in ruby.

For example:

    class MyMalloc

      VERSION = "1.0"

    end

    require "my_malloc/my_malloc"

Setting the `lib_dir` also allows you to build a gem that contains pre-built
extensions for multiple versions of ruby.  (An extension for Ruby 1.9.3 cannot
be used with an extension for Ruby 2.0.0).  `lib/my_malloc.rb` can pick the
correct shared library to install.

Gem specification
-----------------

The final step to building the gem is adding the extconf.rb to the extensions
list in the gemspec:

    Gem::Specification.new "my_malloc", "1.0" do |s|
      # [...]

      s.extensions = %w[ext/my_malloc/extconf.rb]
    end

Now you can build and release the gem!

Extension Naming
----------------

To avoid unintended interactions between gems, it's a good idea for each gem to
keep all of its files in a single directory.  Here are the recommendations for
a gem with the name `<name>`:

1. `ext/<name>` is the directory that contains the source files and
   `extconf.rb`
1. `ext/<name>/<name>.c` is the main source file (there may be others)
1. `ext/<name>/<name>.c` contains a function `Init_<name>`.  (The name
   following `Init_` function must exactly match the name of the extension for
   it to be loadable by require.)
1. `ext/<name>/extconf.rb` calls `create_makefile('<name>/<name>')` only when
   the all the pieces needed to compile the extension are present.
1. The gemspec sets `extensions = ['ext/<name>/extconf.rb']` and includes any
   of the necessary extension source files in the `files` list.
1. `lib/<name>.rb` contains `require '<name>/<name>'` which loads the C
   extension

Further Reading
---------------

* [my_malloc](https://github.com/rubygems/guides/tree/my_malloc) contains the
  source for this extension with some additional comments.
* [README.EXT][README.EXT] describes in greater detail how to build extensions
  in ruby
* [MakeMakefile][mkmf.rb] contains documentation for mkmf.rb, the library
  extconf.rb uses to detect ruby and C library features
* [rake-compiler][rake-compiler] integrates building C and Java extensions into
  your Rakefile in a smooth manner.
* [Writing C extensions part
  1](http://tenderlovemaking.com/2009/12/18/writing-ruby-c-extensions-part-1.html)
  and [part 2](http://tenderlovemaking.com/2010/12/11/writing-ruby-c-extensions-part-2.html))
  by Aaron Patterson
* Interfaces to C libraries can be written using ruby and
  [fiddle](http://ruby-doc.org/stdlib-2.0/libdoc/fiddle/rdoc/Fiddle.html) (part
  of the standard library) or [ruby-ffi](http://github.com/ffi/ffi)

[README.EXT]: https://github.com/ruby/ruby/blob/trunk/README.EXT
[mkmf.rb]: http://ruby-doc.org/stdlib-2.0/libdoc/mkmf/rdoc/MakeMakefile.html
[rake-compiler]: https://github.com/luislavena/rake-compiler

