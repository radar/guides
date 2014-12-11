---
layout: default
title: Name your gem
url: /name-your-gem
previous: /gems-with-extensions
next: /publishing
---

<em class="t-gray">Our recommendation on the use of "_" and "-" in your gem's name.</em>

Here are some examples of our recommendations for naming gems:

Gem name               | Require statement                | Main class or module
---------------------- | -------------------------------- | -----------------------
`ruby_parser`          | `require 'ruby_parser'`          | `RubyParser`
`rdoc-data`            | `require 'rdoc/data'`            | `RDoc::Data`
`net-http-persistent`  | `require 'net/http/persistent'`  | `Net::HTTP::Persistent`
`net-http-digest_auth` | `require 'net/http/digest_auth'` | `Net::HTTP::DigestAuth`

The main goal of these recommendations is to give the user some clue about
how to require the files in your gem. Following these conventions also lets
Bundler require your gem with no extra configuration.

If you publish a gem on [rubygems.org][rubygems] it may be removed if the name
is objectionable, violates intellectual property or the contents of the gem
meet these criteria.  You can report such a gem on the
[RubyGems Support][rubygems-support] site.

[rubygems]: http://rubygems.org
[rubygems-support]: http://help.rubygems.org

Use underscores for multiple words
----------------------------------

If a class or module has multiple words, use underscores to separate them. This
matches the file the user will require, making it easier for the user to start
using your gem.

Use dashes for extensions
-------------------------

If you're adding functionality to another gem, use a dash. This usually
corresponds to a `/` in the require statement (and therefore your gem's
directory structure) and a `::` in the name of your main class or module.

Mix underscores and dashes appropriately
----------------------------------------

If your class or module has multiple words and you're also adding functionality
to another gem, follow both of the rules above. For example,
[`net-http-digest_auth`][digest-gem] adds
[HTTP digest authentication][digest-standard] to `net/http`.
The user will `require 'net/http/digest_auth'` to use the extension
(in class `Net::HTTP::DigestAuth`).

[digest-gem]: https://rubygems.org/gems/net-http-digest_auth
[digest-standard]: http://tools.ietf.org/html/rfc2617

Don't use UPPERCASE letters
---------------------------

OS X and Windows have case-insensitive filesystems by default.  Users may
mistakenly require files from a gem using uppercase letters which will be
non-portable if they move it to a non-windows or OS X system.  While this will
mostly be a newbie mistake we don't need to be confusing them more than
necessary.

Credits
-------

This guide was expanded from [How to Name Gems][how-to-name-gems] by Eric Hodel.

[how-to-name-gems]: https://web.archive.org/web/20130821183311/http://blog.segment7.net/2010/11/15/how-to-name-gems
