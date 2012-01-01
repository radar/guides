---
layout: default
title: Command Reference
previous: /patterns
next: /specification-reference
---

What each `gem` command does, and how to use it.


* [gem build](#gem_build)

* [gem cert](#gem_cert)

* [gem check](#gem_check)

* [gem cleanup](#gem_cleanup)

* [gem contents](#gem_contents)

* [gem dependency](#gem_dependency)

* [gem environment](#gem_environment)

* [gem fetch](#gem_fetch)

* [gem generate_index](#gem_generate_index)

* [gem help](#gem_help)

* [gem install](#gem_install)

* [gem list](#gem_list)

* [gem lock](#gem_lock)

* [gem outdated](#gem_outdated)

* [gem owner](#gem_owner)

* [gem pristine](#gem_pristine)

* [gem push](#gem_push)

* [gem query](#gem_query)

* [gem rdoc](#gem_rdoc)

* [gem search](#gem_search)

* [gem server](#gem_server)

* [gem sources](#gem_sources)

* [gem specification](#gem_specification)

* [gem stale](#gem_stale)

* [gem uninstall](#gem_uninstall)

* [gem unpack](#gem_unpack)

* [gem update](#gem_update)

* [gem which](#gem_which)



## gem build

Build a gem from a gemspec

  
### Arguments


* *GEMSPEC_FILE* -   gemspec file name to build a gem for

  

### Usage

    gem build GEMSPEC_FILE

  
### Description


  

## gem cert

Manage RubyGems certificates and signing settings

  

### Usage

    gem cert

  
### Description


  

## gem check

Check installed gems

  

### Usage

    gem check

  
### Description


  

## gem cleanup

Clean up old versions of installed gems in the local repository

  
### Arguments


* *GEMNAME* -        name of gem to cleanup

  

### Usage

    gem cleanup [GEMNAME ...]

  
### Description

The cleanup command removes old gems from GEM_HOME.  If an older version is
installed elsewhere in GEM_PATH the cleanup command won't touch it.

  

## gem contents

Display the contents of the installed gems

  
### Arguments


* *GEMNAME* -        name of gem to list contents for

  

### Usage

    gem contents GEMNAME [GEMNAME ...]

  
### Description


  

## gem dependency

Show the dependencies of an installed gem

  
### Arguments


* *GEMNAME* -        name of gem to show dependencies for

  

### Usage

    gem dependency GEMNAME

  
### Description


  

## gem environment

Display information about the RubyGems environment

  
### Arguments


* *packageversion* -   display the package version
* *gemdir* -           display the path where gems are installed
* *gempath* -          display path used to search for gems
* *version* -          display the gem format version
* *remotesources* -    display the remote gem servers
* *platform* -         display the supported gem platforms
* *&lt;omitted&gt;* -        display everything

  

### Usage

    gem environment [arg]

  
### Description

The RubyGems environment can be controlled through command line arguments,
gemrc files, environment variables and built-in defaults.

Command line argument defaults and some RubyGems defaults can be set in
~/.gemrc file for individual users and a /etc/gemrc for all users.  A gemrc
is a YAML file with the following YAML keys:

    :sources: A YAML array of remote gem repositories to install gems from
    :verbose: Verbosity of the gem command.  false, true, and :really are the
              levels
    :update_sources: Enable/disable automatic updating of repository metadata
    :backtrace: Print backtrace when RubyGems encounters an error
    :gempath: The paths in which to look for gems
    gem_command: A string containing arguments for the specified gem command

Example:

    :verbose: false
    install: --no-wrappers
    update: --no-wrappers

RubyGems' default local repository can be overridden with the GEM_PATH and
GEM_HOME environment variables.  GEM_HOME sets the default repository to
install into.  GEM_PATH allows multiple local repositories to be searched for
gems.

If you are behind a proxy server, RubyGems uses the HTTP_PROXY,
HTTP_PROXY_USER and HTTP_PROXY_PASS environment variables to discover the
proxy server.

If you are packaging RubyGems all of RubyGems' defaults are in
lib/rubygems/defaults.rb.  You may override these in
lib/rubygems/defaults/operating_system.rb

  

## gem fetch

Download a gem and place it in the current directory

  
### Arguments


* *GEMNAME* -        name of gem to download

  

### Usage

    gem fetch GEMNAME [GEMNAME ...]

  
### Description


  

## gem generate_index

Generates the index files for a gem server directory

  

### Usage

    gem generate_index

  
### Description

The generate_index command creates a set of indexes for serving gems
statically.  The command expects a 'gems' directory under the path given to
the --directory option.  The given directory will be the directory you serve
as the gem repository.

For `gem generate_index --directory /path/to/repo`, expose /path/to/repo via
your HTTP server configuration (not /path/to/repo/gems).

When done, it will generate a set of files like this:

    gems/*.gem                                   # .gem files you want to
                                                 # index

    specs.&lt;version&gt;.gz                           # specs index
    latest_specs.&lt;version&gt;.gz                    # latest specs index
    prerelease_specs.&lt;version&gt;.gz                # prerelease specs index
    quick/Marshal.&lt;version&gt;/&lt;gemname&gt;.gemspec.rz # Marshal quick index file

    # these files support legacy RubyGems
    Marshal.&lt;version&gt;
    Marshal.&lt;version&gt;.Z                          # Marshal full index

The .Z and .rz extension files are compressed with the inflate algorithm.
The Marshal version number comes from ruby's Marshal::MAJOR_VERSION and
Marshal::MINOR_VERSION constants.  It is used to ensure compatibility.

If --rss-host and --rss-gem-host are given an RSS feed will be generated at
index.rss containing gems released in the last two days.

  

## gem help

Provide help on the 'gem' command

  
### Arguments


* *commands* -       List all 'gem' commands
* *examples* -       Show examples of 'gem' usage
* *&lt;command&gt;* -      Show specific help for &lt;command&gt;

  

### Usage

    gem help ARGUMENT

  
### Description


  

## gem install

Install a gem into the local repository

  
### Arguments


* *GEMNAME* -        name of gem to install

  

### Usage

    gem install GEMNAME [GEMNAME ...] [options] -- --build-flags

  
### Description

The install command installs local or remote gem into a gem repository.

For gems with executables ruby installs a wrapper file into the executable
directory by default.  This can be overridden with the --no-wrappers option.
The wrapper allows you to choose among alternate gem versions using _version_.

For example `rake _0.7.3_ --version` will run rake version 0.7.3 if a newer
version is also installed.

If an extension fails to compile during gem installation the gem
specification is not written out, but the gem remains unpacked in the
repository.  You may need to specify the path to the library's headers and
libraries to continue.  You can do this by adding a -- between RubyGems'
options and the extension's build options:

    $ gem install some_extension_gem
    [build fails]
    Gem files will remain installed in \
    /path/to/gems/some_extension_gem-1.0 for inspection.
    Results logged to /path/to/gems/some_extension_gem-1.0/gem_make.out
    $ gem install some_extension_gem -- --with-extension-lib=/path/to/lib
    [build succeeds]
    $ gem list some_extension_gem

    *** LOCAL GEMS ***

    some_extension_gem (1.0)
    $

If you correct the compilation errors by editing the gem files you will need
to write the specification by hand.  For example:

    $ gem install some_extension_gem
    [build fails]
    Gem files will remain installed in \
    /path/to/gems/some_extension_gem-1.0 for inspection.
    Results logged to /path/to/gems/some_extension_gem-1.0/gem_make.out
    $ [cd /path/to/gems/some_extension_gem-1.0]
    $ [edit files or what-have-you and run make]
    $ gem spec ../../cache/some_extension_gem-1.0.gem --ruby &gt; \
               ../../specifications/some_extension_gem-1.0.gemspec
    $ gem list some_extension_gem

    *** LOCAL GEMS ***

    some_extension_gem (1.0)
    $


  

## gem list

Display gems whose name starts with STRING

  
### Arguments


* *STRING* -         start of gem name to look for

  

### Usage

    gem list [STRING]

  
### Description


  

## gem lock

Generate a lockdown list of gems

  
### Arguments


* *GEMNAME* -        name of gem to lock
* *VERSION* -        version of gem to lock

  

### Usage

    gem lock GEMNAME-VERSION [GEMNAME-VERSION ...]

  
### Description

The lock command will generate a list of +gem+ statements that will lock down
the versions for the gem given in the command line.  It will specify exact
versions in the requirements list to ensure that the gems loaded will always
be consistent.  A full recursive search of all effected gems will be
generated.

Example:

    gemlock rails-1.0.0 &gt; lockdown.rb

will produce in lockdown.rb:

    require "rubygems"
    gem 'rails', '= 1.0.0'
    gem 'rake', '= 0.7.0.1'
    gem 'activesupport', '= 1.2.5'
    gem 'activerecord', '= 1.13.2'
    gem 'actionpack', '= 1.11.2'
    gem 'actionmailer', '= 1.1.5'
    gem 'actionwebservice', '= 1.0.0'

Just load lockdown.rb from your application to ensure that the current
versions are loaded.  Make sure that lockdown.rb is loaded *before* any
other require statements.

Notice that rails 1.0.0 only requires that rake 0.6.2 or better be used.
Rake-0.7.0.1 is the most recent version installed that satisfies that, so we
lock it down to the exact version.

  

## gem outdated

Display all gems that need updates

  

### Usage

    gem outdated

  
### Description


  

## gem owner

Manage gem owners on RubyGems.org.

  
### Arguments


* *GEM* -        gem to manage owners for

  

### Usage

    gem owner

  
### Description

Manage gem owners on RubyGems.org.
  

## gem pristine

Restores installed gems to pristine condition from files located in the gem cache

  
### Arguments


* *GEMNAME* -        gem to restore to pristine condition (unless --all)

  

### Usage

    gem pristine [args]

  
### Description

The pristine command compares the installed gems with the contents of the
cached gem and restores any files that don't match the cached gem's copy.

If you have made modifications to your installed gems, the pristine command
will revert them.  After all the gem's files have been checked all bin stubs
for the gem are regenerated.

If the cached gem cannot be found, you will need to use `gem install` to
revert the gem.

If --no-extensions is provided pristine will not attempt to restore gems with
extensions.

  

## gem push

Push a gem up to RubyGems.org

  
### Arguments


* *GEM* -        built gem to push up

  

### Usage

    gem push GEM

  
### Description

Push a gem up to RubyGems.org
  

## gem query

Query gem information in local or remote repositories

  

### Usage

    gem query

  
### Description


  

## gem rdoc

Generates RDoc for pre-installed gems

  
### Arguments


* *GEMNAME* -        gem to generate documentation for (unless --all)

  

### Usage

    gem rdoc [args]

  
### Description

The rdoc command builds RDoc and RI documentation for installed gems.  Use
--overwrite to force rebuilding of documentation.

  

## gem search

Display all gems whose name contains STRING

  
### Arguments


* *STRING* -         fragment of gem name to search for

  

### Usage

    gem search [STRING]

  
### Description


  

## gem server

Documentation and gem repository HTTP server

  

### Usage

    gem server

  
### Description

The server command starts up a web server that hosts the RDoc for your
installed gems and can operate as a server for installation of gems on other
machines.

The cache files for installed gems must exist to use the server as a source
for gem installation.

To install gems from a running server, use `gem install GEMNAME --source
http://gem_server_host:8808`

You can set up a shortcut to gem server documentation using the URL:

    http://localhost:8808/rdoc?q=%s - Firefox
    http://localhost:8808/rdoc?q=* - LaunchBar


  

## gem sources

Manage the sources and cache file RubyGems uses to search for gems

  

### Usage

    gem sources

  
### Description


  

## gem specification

Display gem specification (in yaml)

  
### Arguments


* *GEMFILE* -        name of gem to show the gemspec for
* *FIELD* -          name of gemspec field to show

  

### Usage

    gem specification [GEMFILE] [FIELD]

  
### Description


  

## gem stale

List gems along with access times

  

### Usage

    gem stale

  
### Description


  

## gem uninstall

Uninstall gems from the local repository

  
### Arguments


* *GEMNAME* -        name of gem to uninstall

  

### Usage

    gem uninstall GEMNAME [GEMNAME ...]

  
### Description


  

## gem unpack

Unpack an installed gem to the current directory

  
### Arguments


* *GEMNAME* -        name of gem to unpack

  

### Usage

    gem unpack GEMNAME

  
### Description


  

## gem update

Update the named gems (or all installed gems) in the local repository

  
### Arguments


* *GEMNAME* -        name of gem to update

  

### Usage

    gem update GEMNAME [GEMNAME ...]

  
### Description


  

## gem which

Find the location of a library file you can require

  
### Arguments


* *FILE* -           name of file to find

  

### Usage

    gem which FILE [FILE ...]

  
### Description


  

 