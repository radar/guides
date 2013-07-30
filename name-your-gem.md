---
layout: default
title: Name your gem
previous: /make-your-own-gem
next: /publishing
---

Here is our recommendation on how to name gems:

Use underscores
---------------

* [fancy_require](https://rubygems.org/gems/fancy_require)
* [newrelic_rpm](https://rubygems.org/gems/newrelic_rpm)
* [ruby_parser](https://rubygems.org/gems/ruby_parser)

This matches the file the user will require and makes it easier for the user to
start using your gem.  `gem install my_gem` will be loaded by
`require 'my_gem'`.

Use dashes for extensions
-------------------------

* [net-http-persistent](https://rubygems.org/gems/net-http-persistent)
* [rdoc-data](https://rubygems.org/gems/rdoc-data)
* [autotest-growl](https://rubygems.org/gems/autotest-growl)

If you're adding functionality to another gem use a dash.  The dash is
different-enough from an underscore to be noticeable.  If you tilt the dash a
bit it becomes a slash as well, making it easier for the user to know what to
require.  `gem install net-http-persistent` becomes
`require 'net/http/persistent'`

Mix underscores and dashes appropriately
----------------------------------------

The main goal of these recommendations are to give your user some clue about
how to require the files in the gem.  For example,
[net-http-digest_auth](https://rubygems.org/gems/net-http-digest_auth) adds
[HTTP digest authentication](http://tools.ietf.org/html/rfc2617) to net/http.
The user will `require 'net/http/digest_auth'` to use the extension
(in class Net::HTTP::DigestAuth).  This follows both of the rules above.

Don't use UPPERCASE letters
---------------------------

OS X and Windows have case-insensitive filesystems by default.  Users may
mistakenly require files from a gem using uppercase letters which will be
non-portable if they move it to a non-windows or OS X system.  While this will
mostly be a newbie mistake we don't need to be confusing them more than
necessary.

Credits
-------

This guide was expanded from [How to Name
Gems](http://blog.segment7.net/2010/11/15/how-to-name-gems) by Eric Hodel.

