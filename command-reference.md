---
layout: default
title: Command Reference
url: /command-reference
previous: /patterns
next: /rubygems-org-api
---

<em class="t-gray">What each `gem` command does, and how to use it.</em>

This reference was automatically generated from RubyGems version 2.6.5.

* [gem build](#gem-build)
* [gem cert](#gem-cert)
* [gem check](#gem-check)
* [gem cleanup](#gem-cleanup)
* [gem contents](#gem-contents)
* [gem dependency](#gem-dependency)
* [gem environment](#gem-environment)
* [gem fetch](#gem-fetch)
* [gem generate_index](#gem-generate_index)
* [gem help](#gem-help)
* [gem install](#gem-install)
* [gem list](#gem-list)
* [gem lock](#gem-lock)
* [gem mirror](#gem-mirror)
* [gem open](#gem-open)
* [gem outdated](#gem-outdated)
* [gem owner](#gem-owner)
* [gem pristine](#gem-pristine)
* [gem push](#gem-push)
* [gem query](#gem-query)
* [gem rdoc](#gem-rdoc)
* [gem search](#gem-search)
* [gem server](#gem-server)
* [gem sources](#gem-sources)
* [gem specification](#gem-specification)
* [gem stale](#gem-stale)
* [gem uninstall](#gem-uninstall)
* [gem unpack](#gem-unpack)
* [gem update](#gem-update)
* [gem which](#gem-which)
* [gem yank](#gem-yank)



## gem build

Build a gem from a gemspec

### Usage

    gem build GEMSPEC_FILE [options]


###   Options:

*         -&#8203;-force                    - skip validation of the spec

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMSPEC_FILE* -   gemspec file name to build a gem for

  

  
### Description

The build command allows you to create a gem from a ruby gemspec.

The best way to build a gem is to use a Rakefile and the Gem::PackageTask
which ships with RubyGems.

The gemspec can either be created by hand or extracted from an existing gem
with gem spec:

    $ gem unpack my_gem-1.0.gem
    Unpacked gem: '.../my_gem-1.0'
    $ gem spec my_gem-1.0.gem --ruby > my_gem-1.0/my_gem-1.0.gemspec
    $ cd my_gem-1.0
    [edit gem contents]
    $ gem build my_gem-1.0.gemspec
  

## gem cert

Manage RubyGems certificates and signing settings

### Usage

    gem cert [options]


###   Options:

*     -a, -&#8203;-add CERT                 - Add a trusted certificate.
*     -l, -&#8203;-list \[FILTER\]            - List trusted certificates where the subject contains FILTER
*     -r, -&#8203;-remove FILTER            - Remove trusted certificates where the subject contains FILTER
*     -b, -&#8203;-build EMAIL_ADDR         - Build private key and self-signed certificate for EMAIL_ADDR
*     -C, -&#8203;-certificate CERT         - Signing certificate for -&#8203;-sign
*     -K, -&#8203;-private-key KEY          - Key for -&#8203;-sign or -&#8203;-build
*     -s, -&#8203;-sign CERT                - Signs CERT with the key from -K and the certificate from -C

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  

  
### Description

The cert command manages signing keys and certificates for creating signed
gems.  Your signing certificate and private key are typically stored in
~/.gem/gem-public_cert.pem and ~/.gem/gem-private_key.pem respectively.

To build a certificate for signing gems:

    gem cert --build you@example

If you already have an RSA key, or are creating a new certificate for an
existing key:

    gem cert --build you@example --private-key /path/to/key.pem

If you wish to trust a certificate you can add it to the trust list with:

    gem cert --add /path/to/cert.pem

You can list trusted certificates with:

    gem cert --list

or:

    gem cert --list cert_subject_substring

If you wish to remove a previously trusted certificate:

    gem cert --remove cert_subject_substring

To sign another gem author's certificate:

    gem cert --sign /path/to/other_cert.pem

For further reading on signing gems see `ri Gem::Security`.
  

## gem check

Check a gem repository for added or missing files

### Usage

    gem check [OPTIONS] [GEMNAME ...] [options]


###   Options:

*     -a, -&#8203;-\[no-\]alien               - Report "unmanaged" or rogue files in the gem repository
*         -&#8203;-\[no-\]doctor              - Clean up uninstalled gems and broken specifications
*         -&#8203;-\[no-\]dry-run             - Do not remove files, only report what would be removed
*         -&#8203;-\[no-\]gems                - Check installed gems for problems
*     -v, -&#8203;-version VERSION          - Specify version of gem to check

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -        name of gem to check

  

  
### Description

The check command can list and repair problems with installed gems and
specifications and will clean up gems that have been partially uninstalled.
  

## gem cleanup

Clean up old versions of installed gems

### Usage

    gem cleanup [GEMNAME ...] [options]


###   Options:

*     -n, -d, -&#8203;-dryrun               - Do not uninstall gems

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -        name of gem to cleanup

  

  
### Description

The cleanup command removes old versions of gems from GEM_HOME that are not
required to meet a dependency.  If a gem is installed elsewhere in GEM_PATH
the cleanup command won't delete it.

If no gems are named all gems in GEM_HOME are cleaned.
  

## gem contents

Display the contents of the installed gems

### Usage

    gem contents GEMNAME [GEMNAME ...] [options]


###   Options:

*     -v, -&#8203;-version VERSION          - Specify version of gem to contents
*         -&#8203;-all                      - Contents for all gems
*     -s, -&#8203;-spec-dir a,b,c           - Search for gems under specific paths
*     -l, -&#8203;-\[no-\]lib-only            - Only return files in the Gem's lib_dirs
*         -&#8203;-\[no-\]prefix              - Don't include installed path prefix
*         -&#8203;-\[no-\]show-install-dir    - Show only the gem install dir

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -        name of gem to list contents for

  

  
### Description

The contents command lists the files in an installed gem.  The listing can
be given as full file names, file names without the installed directory
prefix or only the files that are requireable.
  

## gem dependency

Show the dependencies of an installed gem

### Usage

    gem dependency REGEXP [options]


###   Options:

*     -v, -&#8203;-version VERSION          - Specify version of gem to dependency
*         -&#8203;-platform PLATFORM        - Specify the platform of gem to dependency
*         -&#8203;-\[no-\]prerelease          - Allow prerelease versions of a gem
*   - -R, -&#8203;-\[no-\]reverse-dependencies  Include reverse dependencies in the output
*         -&#8203;-pipe                     - Pipe Format (name -&#8203;-version ver)

###   Deprecated Options:

*     -u, -&#8203;-\[no-\]update-sources      - Update local source cache

###   Local/Remote Options:

*     -l, -&#8203;-local                    - Restrict operations to the LOCAL domain
*     -r, -&#8203;-remote                   - Restrict operations to the REMOTE domain
*     -b, -&#8203;-both                     - Allow LOCAL and REMOTE operations
*     -B, -&#8203;-bulk-threshold COUNT     - Threshold for switching to bulk synchronization (default 1000)
*         -&#8203;-clear-sources            - Clear the gem sources
*     -s, -&#8203;-source URL               - Append URL to list of remote gem sources
*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *REGEXP* -         show dependencies for gems whose names start with REGEXP

  

  
### Description

The dependency commands lists which other gems a given gem depends on.  For
local gems only the reverse dependencies can be shown (which gems depend on
the named gem).

The dependency list can be displayed in a format suitable for piping for
use with other commands.
  

## gem environment

Display information about the RubyGems environment

### Usage

    gem environment [arg] [options]


###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *packageversion* -   display the package version
* *gemdir* -           display the path where gems are installed
* *gempath* -          display path used to search for gems
* *version* -          display the gem format version
* *remotesources* -    display the remote gem servers
* *platform* -         display the supported gem platforms
* *&lt;omitted&gt;* -        display everything

  

  
### Description

The environment command lets you query rubygems for its configuration for
use in shell scripts or as a debugging aid.

The RubyGems environment can be controlled through command line arguments,
gemrc files, environment variables and built-in defaults.

Command line argument defaults and some RubyGems defaults can be set in a
~/.gemrc file for individual users and a gemrc in the SYSTEM CONFIGURATION
DIRECTORY for all users. These files are YAML files with the following YAML
keys:

    :sources: A YAML array of remote gem repositories to install gems from
    :verbose: Verbosity of the gem command. false, true, and :really are the
              levels
    :update_sources: Enable/disable automatic updating of repository metadata
    :backtrace: Print backtrace when RubyGems encounters an error
    :gempath: The paths in which to look for gems
    :disable_default_gem_server: Force specification of gem server host on push
    <gem_command>: A string containing arguments for the specified gem command

Example:

    :verbose: false
    install: --no-wrappers
    update: --no-wrappers
    :disable_default_gem_server: true

RubyGems' default local repository can be overridden with the GEM_PATH and
GEM_HOME environment variables. GEM_HOME sets the default repository to
install into. GEM_PATH allows multiple local repositories to be searched for
gems.

If you are behind a proxy server, RubyGems uses the HTTP_PROXY,
HTTP_PROXY_USER and HTTP_PROXY_PASS environment variables to discover the
proxy server.

If you would like to push gems to a private gem server the RUBYGEMS_HOST
environment variable can be set to the URI for that server.

If you are packaging RubyGems all of RubyGems' defaults are in
lib/rubygems/defaults.rb.  You may override these in
lib/rubygems/defaults/operating_system.rb
  

## gem fetch

Download a gem and place it in the current directory

### Usage

    gem fetch GEMNAME [GEMNAME ...] [options]


###   Options:

*     -v, -&#8203;-version VERSION          - Specify version of gem to fetch
*         -&#8203;-platform PLATFORM        - Specify the platform of gem to fetch
*         -&#8203;-\[no-\]prerelease          - Allow prerelease versions of a gem

###   Local/Remote Options:

*     -B, -&#8203;-bulk-threshold COUNT     - Threshold for switching to bulk synchronization (default 1000)
*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations
*     -s, -&#8203;-source URL               - Append URL to list of remote gem sources
*         -&#8203;-clear-sources            - Clear the gem sources

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -        name of gem to download

  

  
### Description

The fetch command fetches gem files that can be stored for later use or
unpacked to examine their contents.

See the build command help for an example of unpacking a gem, modifying it,
then repackaging it.
  

## gem generate_index

Generates the index files for a gem server directory

### Usage

    gem generate_index [options]


###   Options:

*     -d, -&#8203;-directory=DIRNAME        - repository base dir containing gems subdir
*         -&#8203;-\[no-\]modern              - Generate indexes for RubyGems (always true)
*         -&#8203;-update                   - Update modern indexes with gems added since the last update

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  

  
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

    specs.<version>.gz                           # specs index
    latest_specs.<version>.gz                    # latest specs index
    prerelease_specs.<version>.gz                # prerelease specs index
    quick/Marshal.<version>/<gemname>.gemspec.rz # Marshal quick index file

The .rz extension files are compressed with the inflate algorithm.
The Marshal version number comes from ruby's Marshal::MAJOR_VERSION and
Marshal::MINOR_VERSION constants.  It is used to ensure compatibility.
  

## gem help

Provide help on the 'gem' command

### Usage

    gem help ARGUMENT [options]


###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  

  

## gem install

Install a gem into the local repository

### Usage

    gem install GEMNAME [GEMNAME ...] [options] -- --build-flags [options]


###   Options:

*         -&#8203;-platform PLATFORM        - Specify the platform of gem to install
*     -v, -&#8203;-version VERSION          - Specify version of gem to install
*         -&#8203;-\[no-\]prerelease          - Allow prerelease versions of a gem to be installed. (Only for listed gems)

###   Deprecated Options:

*         -&#8203;-\[no-\]rdoc                - Generate RDoc for installed gems Use -&#8203;-document instead
*         -&#8203;-\[no-\]ri                  - Generate ri data for installed gems. Use -&#8203;-document instead
*     -u, -&#8203;-\[no-\]update-sources      - Update local source cache

###   Install/Update Options:

*     -i, -&#8203;-install-dir DIR          - Gem repository directory to get installed gems
*     -n, -&#8203;-bindir DIR               - Directory where binary files are located
*         -&#8203;-\[no-\]document \[TYPES\]    - Generate documentation for installed gems List the documentation types you wish to generate.  For example: rdoc,ri
*         -&#8203;-build-root DIR           - Temporary installation root. Useful for building packages. Do not use this when installing remote gems.
*         -&#8203;-vendor                   - Install gem into the vendor directory. Only for use by gem repackagers.
*     -N, -&#8203;-no-document              - Disable documentation generation
*     -E, -&#8203;-\[no-\]env-shebang         - Rewrite the shebang line on installed scripts to use /usr/bin/env
*     -f, -&#8203;-\[no-\]force               - Force gem to install, bypassing dependency checks
*     -w, -&#8203;-\[no-\]wrappers            - Use bin wrappers for executables Not available on dosish platforms
*     -P, -&#8203;-trust-policy POLICY      - Specify gem trust policy
*         -&#8203;-ignore-dependencies      - Do not install any required dependent gems
*         -&#8203;-\[no-\]format-executable   - Make installed executable names match ruby. If ruby is ruby18, foo_exec will be foo_exec18
*         -&#8203;-\[no-\]user-install        - Install in user's home directory instead of GEM_HOME.
*         -&#8203;-development              - Install additional development dependencies
*         -&#8203;-development-all          - Install development dependencies for all gems (including dev deps themselves)
*         -&#8203;-conservative             - Don't attempt to upgrade gems already meeting version requirement
*         -&#8203;-minimal-deps             - Don't upgrade any dependencies that already meet version requirements
*       - -&#8203;-\[no-\]post-install-message  Print post install message
*     -g, -&#8203;-file \[FILE\]              - Read from a gem dependencies API file and install the listed gems
*         -&#8203;-without GROUPS           - Omit the named groups (comma separated) when installing from a gem dependencies file
*         -&#8203;-default                  - Add the gem's full specification to specifications/default and extract only its bin
*         -&#8203;-explain                  - Rather than install the gems, indicate which would be installed
*         -&#8203;-\[no-\]lock                - Create a lock file (when used with -g/-&#8203;-file)
*         -&#8203;-\[no-\]suggestions         - Suggest alternates when gems are not found

###   Local/Remote Options:

*     -l, -&#8203;-local                    - Restrict operations to the LOCAL domain
*     -r, -&#8203;-remote                   - Restrict operations to the REMOTE domain
*     -b, -&#8203;-both                     - Allow LOCAL and REMOTE operations
*     -B, -&#8203;-bulk-threshold COUNT     - Threshold for switching to bulk synchronization (default 1000)
*         -&#8203;-clear-sources            - Clear the gem sources
*     -s, -&#8203;-source URL               - Append URL to list of remote gem sources
*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -        name of gem to install

  

  
### Description

The install command installs local or remote gem into a gem repository.

For gems with executables ruby installs a wrapper file into the executable
directory by default.  This can be overridden with the --no-wrappers option.
The wrapper allows you to choose among alternate gem versions using _version_.

For example `rake _0.7.3_ --version` will run rake version 0.7.3 if a newer
version is also installed.

Gem Dependency Files
====================

RubyGems can install a consistent set of gems across multiple environments
using `gem install -g` when a gem dependencies file (gem.deps.rb, Gemfile or
Isolate) is present.  If no explicit file is given RubyGems attempts to find
one in the current directory.

When the RUBYGEMS_GEMDEPS environment variable is set to a gem dependencies
file the gems from that file will be activated at startup time.  Set it to a
specific filename or to "-" to have RubyGems automatically discover the gem
dependencies file by walking up from the current directory.

NOTE: Enabling automatic discovery on multiuser systems can lead to
execution of arbitrary code when used from directories outside your control.

Extension Install Failures
==========================

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
    $ gem spec ../../cache/some_extension_gem-1.0.gem --ruby > \
               ../../specifications/some_extension_gem-1.0.gemspec
    $ gem list some_extension_gem

    *** LOCAL GEMS ***

    some_extension_gem (1.0)
    $
  

## gem list

Display local gems whose name matches REGEXP

### Usage

    gem list [REGEXP ...] [options]


###   Options:

*     -i, -&#8203;-\[no-\]installed           - Check for installed gem
*     -I                             - Equivalent to -&#8203;-no-installed
*     -v, -&#8203;-version VERSION          - Specify version of gem to list for use with -&#8203;-installed
*     -d, -&#8203;-\[no-\]details             - Display detailed information of gem(s)
*         -&#8203;-\[no-\]versions            - Display only gem names
*     -a, -&#8203;-all                      - Display all gem versions
*     -e, -&#8203;-exact                    - Name of gem(s) to query on matches the provided STRING
*         -&#8203;-\[no-\]prerelease          - Display prerelease versions

###   Deprecated Options:

*     -u, -&#8203;-\[no-\]update-sources      - Update local source cache

###   Local/Remote Options:

*     -l, -&#8203;-local                    - Restrict operations to the LOCAL domain
*     -r, -&#8203;-remote                   - Restrict operations to the REMOTE domain
*     -b, -&#8203;-both                     - Allow LOCAL and REMOTE operations
*     -B, -&#8203;-bulk-threshold COUNT     - Threshold for switching to bulk synchronization (default 1000)
*         -&#8203;-clear-sources            - Clear the gem sources
*     -s, -&#8203;-source URL               - Append URL to list of remote gem sources
*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *REGEXP* -         regexp to look for in gem name

  

  
### Description

The list command is used to view the gems you have installed locally.

The --details option displays additional details including the summary, the
homepage, the author, the locations of different versions of the gem.

To search for remote gems use the search command.
  

## gem lock

Generate a lockdown list of gems

### Usage

    gem lock GEMNAME-VERSION [GEMNAME-VERSION ...] [options]


###   Options:

*     -s, -&#8203;-\[no-\]strict              - fail if unable to satisfy a dependency

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -        name of gem to lock
* *VERSION* -        version of gem to lock

  

  
### Description

The lock command will generate a list of +gem+ statements that will lock down
the versions for the gem given in the command line.  It will specify exact
versions in the requirements list to ensure that the gems loaded will always
be consistent.  A full recursive search of all effected gems will be
generated.

Example:

    gem lock rails-1.0.0 > lockdown.rb

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
  

## gem mirror

Mirror all gem files (requires rubygems-mirror)

### Usage

    gem mirror [options]


###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  

  
### Description

The mirror command has been moved to the rubygems-mirror gem.
  

## gem open

Open gem sources in editor

### Usage

    gem open GEMNAME [-e EDITOR] [options]


###   Options:

*     -e, -&#8203;-editor EDITOR            - Opens gem sources in EDITOR
*     -v, -&#8203;-version VERSION          - Opens specific gem version

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -      name of gem to open in editor

  

  
### Description

          The open command opens gem in editor and changes current path
          to gem's source directory. Editor can be specified with -e option,
          otherwise rubygems will look for editor in $EDITOR, $VISUAL and
          $GEM_EDITOR variables.
  

## gem outdated

Display all gems that need updates

### Usage

    gem outdated [options]


###   Options:

*         -&#8203;-platform PLATFORM        - Specify the platform of gem to outdated

###   Deprecated Options:

*     -u, -&#8203;-\[no-\]update-sources      - Update local source cache

###   Local/Remote Options:

*     -l, -&#8203;-local                    - Restrict operations to the LOCAL domain
*     -r, -&#8203;-remote                   - Restrict operations to the REMOTE domain
*     -b, -&#8203;-both                     - Allow LOCAL and REMOTE operations
*     -B, -&#8203;-bulk-threshold COUNT     - Threshold for switching to bulk synchronization (default 1000)
*         -&#8203;-clear-sources            - Clear the gem sources
*     -s, -&#8203;-source URL               - Append URL to list of remote gem sources
*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  

  
### Description

The outdated command lists gems you may wish to upgrade to a newer version.

You can check for dependency mismatches using the dependency command and
update the gems with the update or install commands.
  

## gem owner

Manage gem owners of a gem on the push server

### Usage

    gem owner GEM [options]


###   Options:

*     -k, -&#8203;-key KEYNAME              - Use the given API key from ~/.gem/credentials
*     -a, -&#8203;-add EMAIL                - Add an owner
*     -r, -&#8203;-remove EMAIL             - Remove an owner
*         -&#8203;-host HOST                - Use another gemcutter-compatible host

###   Local/Remote Options:

*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEM* -        gem to manage owners for

  

  
### Description

The owner command lets you add and remove owners of a gem on a push
server (the default is https://rubygems.org).

The owner of a gem has the permission to push new versions, yank existing
versions or edit the HTML page of the gem.  Be careful of who you give push
permission to.
  

## gem pristine

Restores installed gems to pristine condition from files located in the gem cache

### Usage

    gem pristine [GEMNAME ...] [options]


###   Options:

*         -&#8203;-all                      - Restore all installed gems to pristine condition
*         -&#8203;-skip=gem_name            - used on -&#8203;-all, skip if name == gem_name
*         -&#8203;-\[no-\]extensions          - Restore gems with extensions in addition to regular gems
*         -&#8203;-only-executables         - Only restore executables
*     -E, -&#8203;-\[no-\]env-shebang         - Rewrite executables with a shebang of /usr/bin/env
*     -v, -&#8203;-version VERSION          - Specify version of gem to restore to pristine condition

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -        gem to restore to pristine condition (unless --all)

  

  
### Description

The pristine command compares an installed gem with the contents of its
cached .gem file and restores any files that don't match the cached .gem's
copy.

If you have made modifications to an installed gem, the pristine command
will revert them.  All extensions are rebuilt and all bin stubs for the gem
are regenerated after checking for modifications.

If the cached gem cannot be found it will be downloaded.

If --no-extensions is provided pristine will not attempt to restore a gem
with an extension.

If --extensions is given (but not --all or gem names) only gems with
extensions will be restored.
  

## gem push

Push a gem up to the gem server

### Usage

    gem push GEM [options]


###   Options:

*     -k, -&#8203;-key KEYNAME              - Use the given API key from ~/.gem/credentials
*         -&#8203;-host HOST                - Push to another gemcutter-compatible host

###   Local/Remote Options:

*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEM* -        built gem to push up

  

  
### Description

The push command uploads a gem to the push server (the default is
https://rubygems.org) and adds it to the index.

The gem can be removed from the index (but only the index) using the yank
command.  For further discussion see the help for the yank command.
  

## gem query

Query gem information in local or remote repositories

### Usage

    gem query [options]


###   Options:

*     -i, -&#8203;-\[no-\]installed           - Check for installed gem
*     -I                             - Equivalent to -&#8203;-no-installed
*     -v, -&#8203;-version VERSION          - Specify version of gem to query for use with -&#8203;-installed
*     -n, -&#8203;-name-matches REGEXP      - Name of gem(s) to query on matches the provided REGEXP
*     -d, -&#8203;-\[no-\]details             - Display detailed information of gem(s)
*         -&#8203;-\[no-\]versions            - Display only gem names
*     -a, -&#8203;-all                      - Display all gem versions
*     -e, -&#8203;-exact                    - Name of gem(s) to query on matches the provided STRING
*         -&#8203;-\[no-\]prerelease          - Display prerelease versions

###   Deprecated Options:

*     -u, -&#8203;-\[no-\]update-sources      - Update local source cache

###   Local/Remote Options:

*     -l, -&#8203;-local                    - Restrict operations to the LOCAL domain
*     -r, -&#8203;-remote                   - Restrict operations to the REMOTE domain
*     -b, -&#8203;-both                     - Allow LOCAL and REMOTE operations
*     -B, -&#8203;-bulk-threshold COUNT     - Threshold for switching to bulk synchronization (default 1000)
*         -&#8203;-clear-sources            - Clear the gem sources
*     -s, -&#8203;-source URL               - Append URL to list of remote gem sources
*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  

  
### Description

The query command is the basis for the list and search commands.

You should really use the list and search commands instead.  This command
is too hard to use.
  

## gem rdoc

Generates RDoc for pre-installed gems

### Usage

    gem rdoc [args] [options]


###   Options:

*         -&#8203;-all                      - Generate RDoc/RI documentation for all installed gems
*         -&#8203;-\[no-\]rdoc                - Generate RDoc HTML
*         -&#8203;-\[no-\]ri                  - Generate RI data
*         -&#8203;-\[no-\]overwrite           - Overwrite installed documents
*     -v, -&#8203;-version VERSION          - Specify version of gem to rdoc

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -        gem to generate documentation for (unless --all)

  

  
### Description

The rdoc command builds documentation for installed gems.  By default
only documentation is built using rdoc, but additional types of
documentation may be built through rubygems plugins and the
Gem.post_installs hook.

Use --overwrite to force rebuilding of documentation.
  

## gem search

Display remote gems whose name matches REGEXP

### Usage

    gem search [REGEXP] [options]


###   Options:

*     -i, -&#8203;-\[no-\]installed           - Check for installed gem
*     -I                             - Equivalent to -&#8203;-no-installed
*     -v, -&#8203;-version VERSION          - Specify version of gem to search for use with -&#8203;-installed
*     -d, -&#8203;-\[no-\]details             - Display detailed information of gem(s)
*         -&#8203;-\[no-\]versions            - Display only gem names
*     -a, -&#8203;-all                      - Display all gem versions
*     -e, -&#8203;-exact                    - Name of gem(s) to query on matches the provided STRING
*         -&#8203;-\[no-\]prerelease          - Display prerelease versions

###   Deprecated Options:

*     -u, -&#8203;-\[no-\]update-sources      - Update local source cache

###   Local/Remote Options:

*     -l, -&#8203;-local                    - Restrict operations to the LOCAL domain
*     -r, -&#8203;-remote                   - Restrict operations to the REMOTE domain
*     -b, -&#8203;-both                     - Allow LOCAL and REMOTE operations
*     -B, -&#8203;-bulk-threshold COUNT     - Threshold for switching to bulk synchronization (default 1000)
*         -&#8203;-clear-sources            - Clear the gem sources
*     -s, -&#8203;-source URL               - Append URL to list of remote gem sources
*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *REGEXP* -         regexp to search for in gem name

  

  
### Description

The search command displays remote gems whose name matches the given
regexp.

The --details option displays additional details from the gem but will
take a little longer to complete as it must download the information
individually from the index.

To list local gems use the list command.
  

## gem server

Documentation and gem repository HTTP server

### Usage

    gem server [options]


###   Options:

*     -p, -&#8203;-port=PORT                - port to listen on
*     -d, -&#8203;-dir=GEMDIR               - directories from which to serve gems multiple directories may be provided
*         -&#8203;-\[no-\]daemon              - run as a daemon
*     -b, -&#8203;-bind=HOST,HOST           - addresses to bind
*     -l, -&#8203;-launch\[=COMMAND\]         - launches a browser window COMMAND defaults to 'start' on Windows and 'open' on all other platforms

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  

  
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

    gem sources [options]


###   Options:

*     -a, -&#8203;-add SOURCE_URI           - Add source
*     -l, -&#8203;-list                     - List sources
*     -r, -&#8203;-remove SOURCE_URI        - Remove source
*     -c, -&#8203;-clear-all                - Remove all sources (clear the cache)
*     -u, -&#8203;-update                   - Update source cache

###   Local/Remote Options:

*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  

  
### Description

RubyGems fetches gems from the sources you have configured (stored in your
~/.gemrc).

The default source is https://rubygems.org, but you may have other sources
configured.  This guide will help you update your sources or configure
yourself to use your own gem server.

Without any arguments the sources lists your currently configured sources:

    $ gem sources
    *** CURRENT SOURCES ***

    https://rubygems.org

This may list multiple sources or non-rubygems sources.  You probably
configured them before or have an old `~/.gemrc`.  If you have sources you
do not recognize you should remove them.

RubyGems has been configured to serve gems via the following URLs through
its history:

* http://gems.rubyforge.org (RubyGems 1.3.6 and earlier)
* http://rubygems.org       (RubyGems 1.3.7 through 1.8.25)
* https://rubygems.org      (RubyGems 2.0.1 and newer)

Since all of these sources point to the same set of gems you only need one
of them in your list.  https://rubygems.org is recommended as it brings the
protections of an SSL connection to gem downloads.

To add a source use the --add argument:

      $ gem sources --add https://rubygems.org
      https://rubygems.org added to sources

RubyGems will check to see if gems can be installed from the source given
before it is added.

To remove a source use the --remove argument:

      $ gem sources --remove http://rubygems.org
      http://rubygems.org removed from sources
  

## gem specification

Display gem specification (in yaml)

### Usage

    gem specification [GEMFILE] [FIELD] [options]


###   Options:

*     -v, -&#8203;-version VERSION          - Specify version of gem to examine
*         -&#8203;-platform PLATFORM        - Specify the platform of gem to specification
*         -&#8203;-\[no-\]prerelease          - Allow prerelease versions of a gem
*         -&#8203;-all                      - Output specifications for all versions of the gem
*         -&#8203;-ruby                     - Output ruby format
*         -&#8203;-yaml                     - Output YAML format
*         -&#8203;-marshal                  - Output Marshal format

###   Deprecated Options:

*     -u, -&#8203;-\[no-\]update-sources      - Update local source cache

###   Local/Remote Options:

*     -l, -&#8203;-local                    - Restrict operations to the LOCAL domain
*     -r, -&#8203;-remote                   - Restrict operations to the REMOTE domain
*     -b, -&#8203;-both                     - Allow LOCAL and REMOTE operations
*     -B, -&#8203;-bulk-threshold COUNT     - Threshold for switching to bulk synchronization (default 1000)
*         -&#8203;-clear-sources            - Clear the gem sources
*     -s, -&#8203;-source URL               - Append URL to list of remote gem sources
*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMFILE* -        name of gem to show the gemspec for
* *FIELD* -          name of gemspec field to show

  

  
### Description

The specification command allows you to extract the specification from
a gem for examination.

The specification can be output in YAML, ruby or Marshal formats.

Specific fields in the specification can be extracted in YAML format:

    $ gem spec rake summary
    --- Ruby based make-like utility.
    ...
  

## gem stale

List gems along with access times

### Usage

    gem stale [options]


###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  

  
### Description

The stale command lists the latest access time for all the files in your
installed gems.

You can use this command to discover gems and gem versions you are no
longer using.
  

## gem uninstall

Uninstall gems from the local repository

### Usage

    gem uninstall GEMNAME [GEMNAME ...] [options]


###   Options:

*     -a, -&#8203;-\[no-\]all                 - Uninstall all matching versions
*     -I, -&#8203;-\[no-\]ignore-dependencies - Ignore dependency requirements while uninstalling
*     -D, -&#8203;-\[no-\]-check-development  - Check development dependencies while uninstalling (default: false)
*     -x, -&#8203;-\[no-\]executables         - Uninstall applicable executables without confirmation
*     -i, -&#8203;-install-dir DIR          - Directory to uninstall gem from
*     -n, -&#8203;-bindir DIR               - Directory to remove binaries from
*         -&#8203;-\[no-\]user-install        - Uninstall from user's home directory in addition to GEM_HOME.
*         -&#8203;-\[no-\]format-executable   - Assume executable names match Ruby's prefix and suffix.
*         -&#8203;-\[no-\]force               - Uninstall all versions of the named gems ignoring dependencies
*         -&#8203;-\[no-\]abort-on-dependent  - Prevent uninstalling gems that are depended on by other gems.
*     -v, -&#8203;-version VERSION          - Specify version of gem to uninstall
*         -&#8203;-platform PLATFORM        - Specify the platform of gem to uninstall
*         -&#8203;-vendor                   - Uninstall gem from the vendor directory. Only for use by gem repackagers.

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -        name of gem to uninstall

  

  
### Description

The uninstall command removes a previously installed gem.

RubyGems will ask for confirmation if you are attempting to uninstall a gem
that is a dependency of an existing gem.  You can use the
--ignore-dependencies option to skip this check.
  

## gem unpack

Unpack an installed gem to the current directory

### Usage

    gem unpack GEMNAME [options]


###   Options:

*         -&#8203;-target=DIR               - target directory for unpacking
*         -&#8203;-spec                     - unpack the gem specification
*     -v, -&#8203;-version VERSION          - Specify version of gem to unpack

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -        name of gem to unpack

  

  
### Description

The unpack command allows you to examine the contents of a gem or modify
them to help diagnose a bug.

You can add the contents of the unpacked gem to the load path using the
RUBYLIB environment variable or -I:

    $ gem unpack my_gem
    Unpacked gem: '.../my_gem-1.0'
    [edit my_gem-1.0/lib/my_gem.rb]
    $ ruby -Imy_gem-1.0/lib -S other_program

You can repackage an unpacked gem using the build command.  See the build
command help for an example.
  

## gem update

Update installed gems to the latest version

### Usage

    gem update GEMNAME [GEMNAME ...] [options]


###   Options:

*         -&#8203;-system \[VERSION\]         - Update the RubyGems system software
*         -&#8203;-platform PLATFORM        - Specify the platform of gem to update
*         -&#8203;-\[no-\]prerelease          - Allow prerelease versions of a gem as update targets

###   Deprecated Options:

*         -&#8203;-\[no-\]rdoc                - Generate RDoc for installed gems Use -&#8203;-document instead
*         -&#8203;-\[no-\]ri                  - Generate ri data for installed gems. Use -&#8203;-document instead
*     -u, -&#8203;-\[no-\]update-sources      - Update local source cache

###   Install/Update Options:

*     -i, -&#8203;-install-dir DIR          - Gem repository directory to get installed gems
*     -n, -&#8203;-bindir DIR               - Directory where binary files are located
*         -&#8203;-\[no-\]document \[TYPES\]    - Generate documentation for installed gems List the documentation types you wish to generate.  For example: rdoc,ri
*         -&#8203;-build-root DIR           - Temporary installation root. Useful for building packages. Do not use this when installing remote gems.
*         -&#8203;-vendor                   - Install gem into the vendor directory. Only for use by gem repackagers.
*     -N, -&#8203;-no-document              - Disable documentation generation
*     -E, -&#8203;-\[no-\]env-shebang         - Rewrite the shebang line on installed scripts to use /usr/bin/env
*     -f, -&#8203;-\[no-\]force               - Force gem to install, bypassing dependency checks
*     -w, -&#8203;-\[no-\]wrappers            - Use bin wrappers for executables Not available on dosish platforms
*     -P, -&#8203;-trust-policy POLICY      - Specify gem trust policy
*         -&#8203;-ignore-dependencies      - Do not install any required dependent gems
*         -&#8203;-\[no-\]format-executable   - Make installed executable names match ruby. If ruby is ruby18, foo_exec will be foo_exec18
*         -&#8203;-\[no-\]user-install        - Install in user's home directory instead of GEM_HOME.
*         -&#8203;-development              - Install additional development dependencies
*         -&#8203;-development-all          - Install development dependencies for all gems (including dev deps themselves)
*         -&#8203;-conservative             - Don't attempt to upgrade gems already meeting version requirement
*         -&#8203;-minimal-deps             - Don't upgrade any dependencies that already meet version requirements
*       - -&#8203;-\[no-\]post-install-message  Print post install message
*     -g, -&#8203;-file \[FILE\]              - Read from a gem dependencies API file and install the listed gems
*         -&#8203;-without GROUPS           - Omit the named groups (comma separated) when installing from a gem dependencies file
*         -&#8203;-default                  - Add the gem's full specification to specifications/default and extract only its bin
*         -&#8203;-explain                  - Rather than install the gems, indicate which would be installed
*         -&#8203;-\[no-\]lock                - Create a lock file (when used with -g/-&#8203;-file)
*         -&#8203;-\[no-\]suggestions         - Suggest alternates when gems are not found

###   Local/Remote Options:

*     -l, -&#8203;-local                    - Restrict operations to the LOCAL domain
*     -r, -&#8203;-remote                   - Restrict operations to the REMOTE domain
*     -b, -&#8203;-both                     - Allow LOCAL and REMOTE operations
*     -B, -&#8203;-bulk-threshold COUNT     - Threshold for switching to bulk synchronization (default 1000)
*         -&#8203;-clear-sources            - Clear the gem sources
*     -s, -&#8203;-source URL               - Append URL to list of remote gem sources
*     -p, -&#8203;-\[no-\]http-proxy \[URL\]    - Use HTTP proxy for remote operations

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEMNAME* -        name of gem to update

  

  
### Description

The update command will update your gems to the latest version.

The update command does not remove the previous version. Use the cleanup
command to remove old versions.
  

## gem which

Find the location of a library file you can require

### Usage

    gem which FILE [FILE ...] [options]


###   Options:

*     -a, -&#8203;-\[no-\]all                 - show all matching files
*     -g, -&#8203;-\[no-\]gems-first          - search gems before non-gems

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *FILE* -           name of file to find

  

  
### Description

The which command is like the shell which command and shows you where
the file you wish to require lives.

You can use the which command to help determine why you are requiring a
version you did not expect or to look at the content of a file you are
requiring to see why it does not behave as you expect.
  

## gem yank

Remove a pushed gem from the index

### Usage

    gem yank GEM -v VERSION [-p PLATFORM] [--key KEY_NAME] [--host HOST] [options]


###   Options:

*     -v, -&#8203;-version VERSION          - Specify version of gem to remove
*         -&#8203;-platform PLATFORM        - Specify the platform of gem to remove
*         -&#8203;-host HOST                - Yank from another gemcutter-compatible host
*     -k, -&#8203;-key KEYNAME              - Use the given API key from ~/.gem/credentials

###   Common Options:

*     -h, -&#8203;-help                     - Get help on this command
*     -V, -&#8203;-\[no-\]verbose             - Set the verbose level of output
*     -q, -&#8203;-quiet                    - Silence command progress meter
*         -&#8203;-silent                   - Silence rubygems output
*         -&#8203;-config-file FILE         - Use this config file instead of default
*         -&#8203;-backtrace                - Show stack backtrace on errors
*         -&#8203;-debug                    - Turn on Ruby debugging
*         -&#8203;-norc                     - Avoid loading any .gemrc file


  
### Arguments


* *GEM* -        name of gem

  

  
### Description

The yank command removes a gem you pushed to a server from the server's
index.

Note that if you push a gem to rubygems.org the yank command does not
prevent other people from downloading the gem via the download link.

Once you have pushed a gem several downloads will happen automatically
via the webhooks.  If you accidentally pushed passwords or other sensitive
data you will need to change them immediately and yank your gem.

If you are yanking a gem due to intellectual property reasons contact
http://help.rubygems.org for permanent removal.  Be sure to mention this
as the reason for the removal request.
  

