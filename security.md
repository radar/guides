---
layout: default
title: Security
previous: /publishing
next: /patterns
---

Security practices are being actively discussed. Check back often.

* [General](#general)
* [Using Gems](#using-gems)
* [Building Gems](#building-gems)
* [Reporting Security Vulnerabilities](#reporting-security-vulnerabilities)

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
of [manual steps on the part of the developer](#building_gems), and there is no
well-established chain of trust for gem signing keys.  Discussion of new signing models such as
X509 and OpenPGP is going on in the [rubygems-trust
wiki](https://github.com/rubygems-trust/rubygems.org/wiki/_pages), the
[RubyGems-Developers list](https://groups.google.com/d/msg/rubygems-developers/lnnGTlfsuYo/TLDcJ2RPSDoJ) and
in [IRC](irc://chat.freenode.net/#rubygems-trust). The goal is to improve (or
replace) the signing system so that it is easy for authors and transparent for
users.

Using Gems
-------

Install with a trust policy.

  * `gem install gemname -P HighSecurity`: All dependent gems must be signed and verified.

  * `gem install gemname -P MediumSecurity`: All signed dependent gems must be verified.

  * `bundle --trust-policy MediumSecurity`: Same as above, except Bundler only recognizes
    the long `--trust-policy` flag, not the short `-P`.

  * *Caveat*: Gem certificates are trusted globally, such that adding a cert.pem for one gem automatically trusts
    all gems signed by that cert.

Verify the checksum, if available

    gem fetch gemname -v version
    ruby -rdigest/sha2 -e "puts Digest::SHA512.new.hexdigest(File.read('gemname-version.gem'))

Know the risks of being pwned, as described by [Benjamin Smith's Hacking with Gems talk](http://lanyrd.com/2013/rulu/scgxzr/)

Building Gems
-------

### Sign with: `gem cert`

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

### Include checksum of released gems in your repository

    require 'digest/sha2'
    built_gem_path = 'pkg/gemname-version.gem'
    checksum = Digest::SHA512.new.hexdigest(File.read(built_gem_path))
    checksum_path = 'checksum/gemname-version.gem.sha512'
    File.open(checksum_path, 'w' ) {|f| f.write(checksum) }
    # add and commit 'checksum_path'

-------

### Not Recommended: OpenPGP signing is [not recommended due to lack of support](http://www.rubygems-openpgp-ca.org/blog/nobody-cares-about-signed-gems.html).

For details, see discussion [with Yorick Peterse](https://github.com/rubygems/guides/pull/70#issuecomment-29007487).

Reporting Security vulnerabilities
-------


### Reporting a security vulnerability with someone else's gem

If you spot a security vulnerability in someone else's gem, then you
first step should be to check whether this is a known vulnerability.

If this looks like a newly discovered vulnerability then you should
content the author(s) privately (i.e. not via a pull request or issue on public
project) explaining the issue, how it can be exploited and ideally offering an
indication of how it might be fixed.

### Reporting a security vulnerability with your own gem

Firstly request a [CVE
identifier](https://en.wikipedia.org/wiki/Common_Vulnerabilities_and_Exposures)
by mailing cve-assign@mitre.org. This identifier will make it easy to
uniquely identify the vulnerability when talking about it.

Secondly work out what people who depend on your gem should do to
resolve the vulnerability. This may involve releasing a patched version of you gem
that you can recommend they upgrade to.

Finally you need to tell people about the vulnerability. Currently there
is no single place to broadcast this information but a good place to
start might be to:

- Send an email to the Ruby Talk mailing list (ruby-talk@ruby-lang.org)
  with the subject prefix \[ANN]\[Security] outlining the vulnerabilty,
  which versions of your gem it affects and what actions those depending
  on the gem should take.

- Add it a to a open source vulnerability database like
  [OSVDB](http://osvdb.org/). You can do this by emailing moderators@osvdb.org
  and/or messaging @osvdb on GitHub or Twitter.

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
