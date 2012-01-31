---
layout: default
title: Contributing to RubyGems
previous: /resources
next: /faqs
---

Looking to contribute to a RubyGems project? You've come to the right place!
There are many development efforts going on right now, and they could use
your help. Just follow the links below to get started contributing or to contact the
project maintainers.

## Core Projects

These projects are under the wing of the core [RubyGems team](https://github.com/rubygems/).

### [RubyGems](https://github.com/rubygems/rubygems)

Ruby's premier packaging system. Bundled with Ruby 1.9+ and available for Ruby 1.8. Any time you run
`gem` at the command line, you're using this project.

[contributors](http://it.isagit.com/rubygems/rubygems) -
[issues](http://github.com/rubygems/rubygems/issues) -
[mailing list](http://rubyforge.org/mailman/listinfo/rubygems-developers)

<p class="avatars">
  <a href="http://github.com/drbrain">
    <img src="https://secure.gravatar.com/avatar/58479f76374a3ba3c69b9804163f39f4?s=32" title="Eric Hodel">
  </a>
  <a href="http://github.com/zenspider">
    <img src="https://secure.gravatar.com/avatar/16c4b19d8670085a428787f8b2438223?s=32" title="Ryan Davis">
  </a>
  <a href="http://github.com/jbarnette">
    <img src="https://secure.gravatar.com/avatar/c237cf537a06b60921c97804679e3b15?s=32" title="John Barnette">
  </a>
  <a href="http://github.com/evanphx">
    <img src="https://secure.gravatar.com/avatar/540cb3b3712ffe045113cb03bab616a2?s=32" title="Evan Phoenix">
  </a>
</p>

*Code Guidelines*
+ New features should be coupled with tests.
+ Ensure that your code blends well with ours (eg, no trailing whitespace, match indentation and coding style).
+ Don't modify the history file or version number.
+ If you have any questions, just ask us on IRC in #rubygems or file [an issue][1].

[0]: http://github.com/rubygems/rubygems
[1]: http://github.com/rubygems/rubygems/issues
[2]: http://help.rubygems.org

### [RubyGems.org](https://github.com/rubygems/rubygems.org)

The Ruby community's gem hosting service. Provides a better API for accessing,
deploying, and managing gems along with clear and accessible project pages.

[site](http://rubygems.org) -
[contributors](http://it.isagit.com/rubygems/rubygems.org) -
[issues](http://github.com/rubygems/rubygems.org/issues) -
[mailing list](https://groups.google.com/forum/#!forum/gemcutter)

<p class="avatars">
  <a href="http://github.com/qrush">
    <img src="https://secure.gravatar.com/avatar/eb8975af8e49e19e3dd6b6b84a542e26?s=32" title="Nick Quaranto">
  </a>
  <a href="http://github.com/sferik">
    <img src="https://secure.gravatar.com/avatar/1f74b13f1e5c6c69cb5d7fbaabb1e2cb?s=32" title="Erik Michaels-Ober">
  </a>
  <a href="http://github.com/cldwalker">
    <img src="https://secure.gravatar.com/avatar/8f0660cdc9f5d91c7d97456f8f0be8c7?s=32" title="Gabriel Horner">
  </a>
  <a href="http://github.com/cmeiklejohn">
    <img src="https://secure.gravatar.com/avatar/3e09fee7b359be847ed5fa48f524a3d3?s=32" title="Christopher Meiklejohn">
  </a>
</p>

### [RubyGems Guides](https://github.com/rubygems/guides)

The central home for RubyGems documentation, including tutorials and reference material.
User-contributed guides are more than welcome and encouraged!

[site](http://guides.rubygems.org) -
[contributors](http://it.isagit.com/rubygems/guides) -
[issues](http://github.com/rubygems/guides/issues)

<p class="avatars">
  <a href="http://github.com/qrush">
    <img src="https://secure.gravatar.com/avatar/eb8975af8e49e19e3dd6b6b84a542e26?s=32" title="Nick Quaranto">
  </a>
  <a href="http://github.com/sandal">
    <img src="https://secure.gravatar.com/avatar/31e038e4e9330f6c75ccfd1fca8010ee?s=32" title="Gregory Brown">
  </a>
  <a href="http://github.com/ffmike">
    <img src="https://secure.gravatar.com/avatar/a54251b745d59735ea5e9f0656a5d58d?s=32" title="Mike Gunderloy">
  </a>
</p>

### [RubyGems Testers](https://github.com/rubygems/rubygems-test)

A community effort to document the test results for various gems,
on various machine architectures.

[site](http://test.rubygems.org/) -
[contributors](http://it.isagit.com/rubygems/rubygems-test) -
[issues](https://github.com/rubygems/rubygems-test/issues)

<p class="avatars">
  <a href="http://github.com/bluepojo">
    <img src="https://secure.gravatar.com/avatar/4b1e87301a43b027903617a98d61831a?s=32" title="Josiah Kiehl">
  </a>
  <a href="http://github.com/erikh">
    <img src="https://secure.gravatar.com/avatar/1b641a79b2717f2d582ad455b40d5b89?s=32" title="Erik Hollensbe">
  </a>
</p>

### [Gem Whisperer](https://github.com/rubygems/gemwhisperer)

An example of how to use [RubyGems.org's
webhooks](http://guides.rubygems.org/rubygems-org-api/#webhook) to listen to every gem being
pushed. Currently powers [m.rubygems.org](http://m.rubygems.org) and
[@rubygems](http://twitter.com/rubygems).

[site](http://m.rubygems.org/) -
[contributors](http://it.isagit.com/rubygems/gemwhisperer) -
[issues](https://github.com/rubygems/gemwhisperer/issues)

<p class="avatars">
  <a href="http://github.com/qrush">
    <img src="https://secure.gravatar.com/avatar/eb8975af8e49e19e3dd6b6b84a542e26?s=32" title="Nick Quaranto">
  </a>
  <a href="http://github.com/laserlemon">
    <img src="https://secure.gravatar.com/avatar/0887991a8846577a6aa85433d6ab3ea2?s=32" title="Steve Richert">
  </a>
</p>

### [RubyGems.org API Library](https://github.com/rubygems/gems)

A Ruby implementation of the various API endpoints available on RubyGems.org.
If you're writing a service in Ruby to interact with gems available to the
community, check this out!

[contributors](http://it.isagit.com/rubygems/gems) -
[issues](https://github.com/rubygems/gems/issues)

<p class="avatars">
  <a href="http://github.com/sferik">
    <img src="https://secure.gravatar.com/avatar/1f74b13f1e5c6c69cb5d7fbaabb1e2cb?s=32" title="Erik Michaels-Ober">
  </a>
</p>

### [RubyGems Search](https://github.com/rubygems/search)

A souped-up implementation of search on RubyGems.org, using Solr. Still not
100% done yet, but hopefully will replace the search box on RubyGems.org soon!

[contributors](http://it.isagit.com/rubygems/search) -
[issues](https://github.com/rubygems/search/issues)

<p class="avatars">
  <a href="http://github.com/nz">
    <img src="https://secure.gravatar.com/avatar/5198f305281b34927f936ba77cffcbf6?s=32" title="Nick Zadrozny">
  </a>
</p>

### [RubyGems Mirror](https://github.com/rubygems/rubygems-mirror/wiki/Mirroring-2.0)

The current state of mirroring RubyGems is frankly embarrassing. We need
RubyGems to be highly available all over the world, no more excuses! Discussion
is going on in the [rubygems-mirror
wiki](https://github.com/rubygems/rubygems-mirror/wiki/Mirroring-2.0) on how
to improve it.

[contributors](http://it.isagit.com/rubygems/rubygems-mirror) -
[issues](https://github.com/rubygems/rubygems-mirror/issues)

<p class="avatars">
  <a href="http://github.com/raggi">
    <img src="https://secure.gravatar.com/avatar/b19b02a49b433c9e2e6e6c43785d2bfb?s=32" title="James Tucker">
  </a>
</p>

## Ecosystem Projects

These projects are outside of the RubyGems core, but work closely with RubyGems to improve the gem experience for everyone.

### [Bundler](https://github.com/carlhuda/bundler)

Bundler manages an application's dependencies through its entire life across
many machines systematically and repeatably.

[site](http://gembundler.com/) -
[contributors](http://it.isagit.com/carlhuda/bundler) -
[issues](https://github.com/carlhuda/bundler/issues) -
[mailing list](https://groups.google.com/forum/#!forum/ruby-bundler)

<p class="avatars">
  <a href="http://github.com/indirect">
    <img src="https://secure.gravatar.com/avatar/fb389f1e8b98d5d03be29e9dd309b3be?s=32" title="Andre Arko">
  </a>
  <a href="http://github.com/hone">
    <img src="https://secure.gravatar.com/avatar/efb7c66871043330ce1310a9bdd0aaf6?s=32" title="Terence Lee">
  </a>
  <a href="http://github.com/wycats">
    <img src="https://secure.gravatar.com/avatar/428167a3ec72235ba971162924492609?s=32" title="Yehuda Katz">
  </a>
  <a href="http://github.com/carllerche">
    <img src="https://secure.gravatar.com/avatar/da5274b27cc6c0f505495bf5d504575d?s=32" title="Carl Lerche">
  </a>
</p>

### [Isolate](http://github.com/jbarnette/isolate)

A simple gem sandbox that makes sure your application has the exact gem
versions you require. It does not perform dependency resolution like Bundler.

[contributors](http://it.isagit.com/jbarnette/isolate) -
[issues](https://github.com/jbarnette/isolate/issues)

<p class="avatars">
  <a href="http://github.com/jbarnette">
    <img src="https://secure.gravatar.com/avatar/c237cf537a06b60921c97804679e3b15?s=32" title="John Barnette">
  </a>
</p>

### [RubyDoc.info](https://github.com/lsegal/rubydoc.info)

A fantastic provider of [YARD](http://yardoc.org) documentation for every
RubyGem available. Push a gem, and you get docs created instantly!
RubyGems.org links to this site and it uses [RubyGems.org's
webhooks](http://guides.rubygems.org/rubygems-org-api/#webhook) as well.

[site](http://rubydoc.info) -
[contributors](http://it.isagit.com/lsegal/rubydoc.info) -
[issues](https://github.com/lsegal/rubydoc.info/issues) -
[mailing list](https://groups.google.com/forum/#!forum/yardoc)

<p class="avatars">
  <a href="http://github.com/indirect">
    <img src="https://secure.gravatar.com/avatar/fb389f1e8b98d5d03be29e9dd309b3be?s=32" title="Andre Arko">
  </a>
  <a href="http://github.com/hone">
    <img src="https://secure.gravatar.com/avatar/efb7c66871043330ce1310a9bdd0aaf6?s=32" title="Terence Lee">
  </a>
</p>

### [Stickler](https://github.com/copiousfreetime/stickler)

Stickler is a great way to run and organize an internal gem server in your
organization. It helps with mirroring gems and providing a gem source to add
internal or proprietary code to.

[contributors](http://it.isagit.com/copiousfreetime/stickler) -
[issues](https://github.com/copiousfreetime/stickler/issues)

<p class="avatars">
  <a href="http://github.com/copiousfreetime">
    <img src="https://secure.gravatar.com/avatar/cff2d90ae70bbbb5d4865d8412159f85?s=32" title="Jeremy Hinegardner">
  </a>
</p>

### [Geminabox](https://github.com/cwninja/geminabox)

Need simple RubyGems hosting? Geminabox can do that! This project provides an
easy to setup way to host RubyGems internally and allow uploading of gems
without much hassle.

[contributors](http://it.isagit.com/cwninja/geminabox) -
[issues](https://github.com/cwninja/geminabox/issues)

<p class="avatars">
  <a href="http://github.com/cwninja">
    <img src="https://secure.gravatar.com/avatar/f61c5838432c656ea88dd77a56a40f52?s=32" title="Tom Leal">
  </a>
</p>

## Your idea?

We'd love for your new idea to be on this list. If you're working on a
RubyGems related project, just [fork this
repo](http://github.com/rubygems/guides) and add the link!


