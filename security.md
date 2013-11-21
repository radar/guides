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

### Official: `gem cert`

To build:

1) Create self-signed gem cert

    cd ~/.ssh
    gem cert --build your@email.com
    chmod 600 gem-p*

- use the email address you specify in your gemspecs

2) Configure gemspec with cert

Add cert public key to your repository

    cd /path/to/your/gem
    mkdir certs
    cp ~/.ssh/gem-public_cert.pem certs/yourhandle.pem
    git add certs/yourhandle.pem

Add cert paths to your gemspec

    s.cert_chain  = ['certs/yourhandle.pem']
    s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/

3) Add your own cert to your approved list, just like anyone else

    gem cert --add certs/yourhandle.pem

4) Build gem and test that you can install it

    gem build gemname.gemspec
    gem install gemname-version.gem -P HighSecurity
    # or -P MediumSecurity if your gem depends on unsigned gems

5) Example text for installation documentation

> MetricFu is cryptographically signed. To be sure the gem you install hasn't been tampered with:
>
> Add my public key (if you haven't already) as a trusted certificate
>
> `gem cert --add <(curl -Ls https://raw.github.com/metricfu/metric_fu/master/certs/bf4.pem)`
>
> `gem install metric_fu -P MediumSecurity`
>
> The MediumSecurity trust profile will verify signed gems, but allow the installation of unsigned dependencies.
>
> This is necessary because not all of MetricFu's dependencies are signed, so we cannot use HighSecurity.

-------

### Not Recommended: [Rubygems OpenPGP signing](https://web.archive.org/web/20130914152133/http://www.rubygems-openpgp-ca.org/), [gem](https://github.com/grant-olson/rubygems-openpgp)
About: [Video](https://vimeo.com/59297058), [Slides](https://docs.google.com/a/grant-olson.net/viewer?a=v&pid=sites&srcid=Z3JhbnQtb2xzb24ubmV0fGdyYW50LXMtc3R1ZmZ8Z3g6MTg5MWZkNjU3ZGEyZDY5Yg)

OpenPGP signing is [not recommended due to lack of support](http://www.rubygems-openpgp-ca.org/blog/nobody-cares-about-signed-gems.html).
Especially, [do not use the rubygems-openpgpg certificate authority.](https://github.com/grant-olson/rubygems-openpgp/issues/34#issuecomment-29006704)

Here's how to use for an individual's signed gem.

Assumes you've already generated a signing key with `gpg --gen-key`

To build:

    $ gem install rubygems-openpgp
    $ gem build gemname.gemspec --sign
    # or
    $ gem sign pkg/gemname-version.gem

To [install](https://github.com/grant-olson/stackdriver-ruby/blob/505d928/README.md#software-verification):

    The public key 3649F444 registered to "Yorick Peterse" using Email address yorickpeterse@gmail.com
    $ gem install rubygems-openpgp
    $ gpg --recv-keys 3649F444
    $ gpg --lsign 3649F444          # Trust this key. You verified it yourself, right?
    $ gem install ruby-lint --trust # Trust includes verification

------

### Alternative: Include checksum of released gems in your repository

For example, see the [ruby-lint gem](https://github.com/YorickPeterse/ruby-lint/blob/0858d8f841f604398f40ba3a40777d68c03a543b/task/checksum.rake).

To build:

    require 'digest/sha2'
    gem_path = 'pkg/ruby-lint-0.9.1.gem'
    checksum = Digest::SHA512.new.hexdigest(File.read(gem_path))
    checksum_path = 'checksum/ruby-lint-0.9.1.gem.sha512'
    File.open(checksum_path, 'w' ) {|f| f.write(checksum) }

To verify:

    gem fetch ruby-lint -v 0.9.1
    ruby -rdigest/sha2 -e "puts Digest::SHA512.new.hexdigest(File.read('ruby-lint-0.9.1.gem'))

Credits
-------

Several sources were used for content for this guide:

* [How to cryptographically sign your RubyGem](http://www.benjaminfleischer.com/2013/11/08/how-to-sign-your-rubygem-cert/) - Step-by-step guide
* [Signing rubygems - Pasteable instructions](http://developer.zendesk.com/blog/2013/02/03/signing-gems/)
* [Twitter gem gemspec](https://github.com/sferik/twitter/blob/master/twitter.gemspec)
* [RubyGems Trust Model Overview](https://github.com/rubygems-trust/rubygems.org/wiki/Overview), [doc](http://goo.gl/ybFIO)
* [Let’s figure out a way to start signing RubyGems](http://tonyarcieri.com/lets-figure-out-a-way-to-start-signing-rubygems)
* [A Practical Guide to Using Signed Ruby Gems - Part 3: Signing your Own](http://blog.meldium.com/home/2013/3/6/signing-gems-how-to)
* Also see the [Resources](/resources) page.
