---
layout: default
title: Publishing your gem
previous: /name-your-gem
next: /patterns
---

Ways to share your gem code with other users.

* [Introduction](#introduction)
* [Sharing Source Code](#sharing_source_code)
* [Serving Your Own Gems](#serving_your_own_gems)
* [Publishing to RubyGems.org](#publishing_to_rubygemsorg)
* [Gem Security](#gem_security)

Introduction
------------

Now that you've [created your gem](/make-your-own-gem), you're probably ready
to share it.  While it is perfectly reasonable to create private gems solely to
organize the code in large private projects, it's more common to build gems so
that they can be used by multiple projects.  This guide discusses the various
ways that you can share your gem with the world.

Sharing Source Code
-------------------

The simplest way (from the author's perspective) to share a gem for other
developers' use is to distribute it in source code form. If you place the full
source code for your gem on a public git repository (often, though not always,
this means sharing it via [GitHub](https://github.com)), then other users can
install it with [Bundler's git functionality](http://gembundler.com/git.html).

For example, you can install the latest code for the wicked_pdf gem in a
project by including this line in your Gemfile:

    gem "wicked_pdf", :git => "git://github.com/mileszs/wicked_pdf.git"

> Installing a gem directly from a git repository is a feature of Bundler, not
> a feature of RubyGems. Gems installed this way will not show up when you run
> `gem list`.

Serving Your Own Gems
---------------------

If you want to control who can install a gem, or directly track the activity
surrounding a gem, then you'll want to set up a private gem server. You can
[set up your own gem server](/run-your-own-gem-server) or use a commercial
service such as [Gemfury](http://www.gemfury.com/).

See the [Resources](/resources) guide for an up-to-date listing of options for
private gem servers.

Publishing to RubyGems.org
--------------------------

The simplest way to distribute a gem for public consumption is to use
[RubyGems.org](https://rubygems.org/).  Gems that are published to RubyGems.org
can be installed via the `gem install` command or through the use of tools such
as Isolate or Bundler.

To begin, you'll need to create an account on RubyGems.org. Visit the [sign
up](https://rubygems.org/users/new) page and supply an email address that you
control, a handle (username) and a password.

After creating the account, use your email and password when pushing the gem.
(RubyGems saves the credentials in ~/.gem/credentials for you so you only need
to log in once.)

To publish version 0.1.0 of a new gem named 'squid-utils':

    $ gem push squid-utils-0.1.0.gem
    Enter your RubyGems.org credentials.
    Don't have an account yet? Create one at https://rubygems.org/sign_up
       Email:   gem_author@example
    Password:
    Signed in.
    Pushing gem to RubyGems.org...
    Successfully registered gem: squid-utils (0.1.0)

Congratulations! Your new gem is now ready for any ruby user in the world to
install!

Gem Security
------------

Installing a gem allows that gem's code to run in the context of your
application. Clearly this has security implications: installing a malicious gem
on a server could ultimately result in that server being completely penetrated
by the gem's author. Because of this, the security of gem code is a topic of
active discussion within the Ruby community.

RubyGems has had the ability to [cryptographically sign
gems](http://docs.rubygems.org/read/chapter/21) since version 0.8.11. This
signing works by using the `gem cert` command to create a key pair, and then
packaging signing data inside the gem itself. The `gem install` command
optionally lets you set a security policy, and you can verify the signing key
for a gem before you install it.

However, this method of securing gems is not widely used. It requires a number
of manual steps on the part of the developer, and there is no well-established
chain of trust for gem signing keys. Discussion of new signing models using
X509 or OpenPGP is going on in the [rubygems-trust
wiki](https://github.com/rubygems-trust/rubygems.org/wiki/_pages) and
in [IRC](irc://chat.freenode.net/#rubygems-trust). The goal is to improve (or
replace) the signing system so that it is easy for authors and transparent for
users.

