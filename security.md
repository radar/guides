---
layout: default
title: Security
previous: /publishing
next: /patterns
---

Security practices are being actively discussed. Check back often.

* [General](#general)
* [Using Gems](#using_gems)
* [Building Gems](#building_gems)

General
-------

Installing a gem allows that gem's code to run in the context of your
application. Clearly this has security implications: installing a malicious gem
on a server could ultimately result in that server being completely penetrated
by the gem's author. Because of this, the security of gem code is a topic of
active discussion within the Ruby community.

RubyGems has had the ability to [cryptographically sign
gems](http://rubygems.rubyforge.org/rubygems-update/Gem/Security.html) since version 0.8.11. This
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

Using Gems
-------

* Install with a trust policy.
  * `gem install gemname -P HighSecurity`: All dependent gems must be signed and verified.
  * `gem install gemname -P MediumSecurity`: All signed dependent gems must be verified.
  * `bundle --trust-policy MediumSecurity`: Same as above, except Bundler only recognizes
    the long `--trust-policy` flag, not the short `-P`.
* Risks of being pwned, as described by [Benjamin Smith's Hacking with Gems talk](http://lanyrd.com/2013/rulu/scgxzr/)

Building Gems
-------

* `gem cert`
  * [How to cryptographically sign your RubyGem](http://www.benjaminfleischer.com/2013/11/08/how-to-sign-your-rubygem-cert/) - Step-by-step guide
* openpgp signing with [rubygems-openpgp](https://github.com/grant-olson/rubygems-openpgp)
  * For example, see the [ruby-lint gem](https://github.com/YorickPeterse/ruby-lint/blob/0858d8f841/README.md#security)

Credits
-------

Several sources were used for content for this guide:

* [Signing rubygems - Pasteable instructions](http://developer.zendesk.com/blog/2013/02/03/signing-gems/)
* [Twitter gem gemspec](https://github.com/sferik/twitter/blob/master/twitter.gemspec)
* [RubyGems Trust Model Overview](https://github.com/rubygems-trust/rubygems.org/wiki/Overview), [doc](http://goo.gl/ybFIO)
* [Let’s figure out a way to start signing RubyGems](http://tonyarcieri.com/lets-figure-out-a-way-to-start-signing-rubygems)
* [A Practical Guide to Using Signed Ruby Gems - Part 3: Signing your Own](http://blog.meldium.com/home/2013/3/6/signing-gems-how-to)
* Alternative: [Rubygems OpenPGP signing](https://web.archive.org/web/20130914152133/http://www.rubygems-openpgp-ca.org/), [gem](https://github.com/grant-olson/rubygems-openpgp)
* Also see the [Resources](/resources) page.
