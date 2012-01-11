---
layout: default
title: Frequently Asked Questions
previous: /contributing
next: /plugins
---

The RubyGems development team has gotten a lot of support requests over the
years, and this is a list of the questions users both new and old that
frequently pop up.

* [I installed gems with `--user-install` and their commands are not available](#user-install)


<a id="user-install"> </a>
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
