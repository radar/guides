---
layout: default
title: Frequently Asked Questions
url: /faqs
previous: /contributing
next: /plugins
---

<em class="t-gray">More of the "why" and "wtf" than "how".</em>

The RubyGems development team has gotten a lot of support requests over the
years, and this is a list of the questions users both new and old that
frequently pop up.

* [I installed gems with `--user-install` and their commands are not available](#user-install)
* [How can I trust Gem code that's automatically downloaded?](#security)
* [Why does `require 'some-gem'` fail?](#require-fail)
* [Why does require return false when loading a file from a gem?](#require-false)

We also answer questions on the [RubyGems Support](http://help.rubygems.org/) site and on IRC
in #rubygems. Some of the information you can find on the support site includes:

* [Installing gems with no network](http://help.rubygems.org/kb/rubygems/installing-gems-with-no-network)
* [Why do I get HTTP Response 302 or 301 when installing a gem?](http://help.rubygems.org/kb/rubygems/why-do-i-get-http-response-302-or-301-when-installing-a-gem)
* [RubyGems Upgrade Issues](http://help.rubygems.org/kb/rubygems/rubygems-upgrade-issues)

<a id="user-install"></a>

I installed gems with `--user-install` and their commands are not available
---------------------------------------------------------------------------

When you use the `--user-install` option, RubyGems will install the gems to a
directory inside your home directory, something like `~/.gem/ruby/1.9.1`. The
commands provided by the gems you installed will end up in
`~/.gem/ruby/1.9.1/bin`. For the programs installed there to be available for
you, you need to add `~/.gem/ruby/1.9.1/bin` to your `PATH` environment
variable.

For example, if you use bash you can add that directory to your `PATH` by
adding code like this to your `~/.bashrc` file:

    if which ruby >/dev/null && which gem >/dev/null; then
        PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
    fi

After adding this code to your `~/.bashrc`, you need to restart your shell for
the changes to take effect. You can do this by opening a new terminal window or
by running `exec $SHELL` in the window you already have open.

<a id="security"></a>

How can I trust Gem code that's automatically downloaded?
---------------------------------------------------------

The same way you can trust any other code you install from the net: ultimately,
you can't. You are responsible for knowing the source of the gems that you are
using. In a setting where security is critical, you should only use known-good
gems, and possibly perform your own security audit on the gem code.

The Ruby community is discussing ways to make gem code more secure in the future,
using some public-key infrastructure. To see the progress of this discussion, visit the
[rubygems-trust](https://github.com/rubygems-trust) organization on GitHub.

<a id="require-fail"></a>

Why does `require 'some-gem'` fail?
-----------------------------------

Not every library has a strict mapping between the name of the gem and the name of
the file you need to require. First you should check to see if the files match correctly:

    $ gem list RedCloth

    *** LOCAL GEMS ***

    RedCloth (4.1.1)
    $ ruby -rubygems -e 'require "RedCloth"'
    /Library/Ruby/Site/1.8/rubygems/custom_require.rb:31:in `gem_original_require': no such file to load -- RedCloth (LoadError)
      from /Library/Ruby/Site/1.8/rubygems/custom_require.rb:31:in `require'
      from -e:1
    $ gem contents --no-prefix RedCloth | grep lib
    lib/case_sensitive_require/RedCloth.rb
    lib/redcloth/erb_extension.rb
    lib/redcloth/formatters/base.rb
    lib/redcloth/formatters/html.rb
    lib/redcloth/formatters/latex.rb
    lib/redcloth/formatters/latex_entities.yml
    lib/redcloth/textile_doc.rb
    lib/redcloth/version.rb
    lib/redcloth.rb
    $ ruby -rubygems -e 'require "redcloth"'
    $ # success!

If you’re requiring the correct file, maybe `gem` is using a different ruby than `ruby`:

    $ which ruby
    /usr/local/bin/ruby
    $ gem env | grep 'RUBY EXECUTABLE'
       - RUBY EXECUTABLE: /usr/local/bin/ruby1.9

In this instance we’ve got two ruby installations so that `gem` uses a different version than `ruby`. You can probably fix this by adjusting a symlink:

    $ ls -l /usr/local/bin/ruby*
    lrwxr-xr-x  1 root  wheel       76 Jan 20  2010 /usr/local/bin/ruby@ -> /usr/local/bin/ruby1.8
    -rwxr-xr-x  1 root  wheel  1213160 Jul 15 16:36 /usr/local/bin/ruby1.8*
    -rwxr-xr-x  1 root  wheel  2698624 Jul  6 19:30 /usr/local/bin/ruby1.9*
    $ ls -l /usr/local/bin/gem*
    lrwxr-xr-x  1 root  wheel   76 Jan 20  2010 /usr/local/bin/gem@ -> /usr/local/bin/gem1.9
    -rwxr-xr-x  1 root  wheel  550 Jul 15 16:36 /usr/local/bin/gem1.8*
    -rwxr-xr-x  1 root  wheel  550 Jul  6 19:30 /usr/local/bin/gem1.9*

You may also need to give `irb` the same treatment.

<a id="require-false"></a>

Why does require return false when loading a file from a gem?
-------------------------------------------------------------

Require returns false when loading a file from a gem. Usually require will return
true when it has loaded correctly. What’s wrong?

Nothing's wrong. Well, something. But nothing you need to worry about.

A false return from the require method does not indicate an error. It just
means that the file has already been loaded.

RubyGems has a feature that allows a file to be automatically loaded
when a gem is activated (i.e. selected). When you require a file that is
in an inactive gem, the RubyGems software will activate that gem for you.
During that activation, any autoloaded files will be loaded for you.

So, by the time your require statement actually does the work of loading
the file, it has already been autoloaded via the gem activation, and
therefore the statement returns false.

