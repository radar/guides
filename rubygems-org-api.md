---
layout: default
title: RubyGems.org API
url: /rubygems-org-api
previous: /command-reference
next: /run-your-own-gem-server
---

<em class="t-gray">Details on interacting with RubyGems.org over HTTP.</em>

> NOTE: The API is a work in progress, and [can use your help!](https://github.com/rubygems/gemcutter)
> RubyGems itself and the
> [gemcutter gem](https://rubygems.org/gems/gemcutter) use the API to push gems,
> add owners, and more.

* [API Authorization](#api-authorization): How to authenticate with RubyGems.org
* [Gem Methods](#gem-methods): Query or create gems to be hosted
* [Gem Version Methods](#gem-version-methods): Query for information about
  versions of a particular gem
* [Gem Download Methods](#gem-download-methods): Query for download statistics
* [Owner Methods](#owner-methods): Manage owners for gems
* [Webhook Methods](#webhook-methods): Manage notifications for when gems are
  pushed
* [Activity Methods](#activity-methods): Query for information about site-wide
  activity
* [Misc Methods](#misc-methods): Various other interactions with the site

API Authorization
-----------------

Some API calls require an Authorization header. To find your API key, click on
your username when logged in to [RubyGems.org](http://rubygems.org) and then click on 'Edit Profile'. Here's an example of
using an API key:

    $ curl -H 'Authorization:YOUR_API_KEY' \
      https://rubygems.org/api/v1/some_api_call.json

Ruby Library
------------

You can also interact with RubyGems.org using Ruby.

The [gems](https://rubygems.org/gems/gems) client provides a Ruby interface to
all the resources listed below. This library has
[full documentation](http://rdoc.info/gems/gems) that includes some basic usage
examples in the README. You can install the library with the command:

    gem install gems

Gem Methods
-----------

### GET - `/api/v1/gems/[GEM NAME].(json|yaml)`

Returns some basic information about the given gem. See below an example response for the gem "rails" in JSON format:

    $ curl https://rubygems.org/api/v1/gems/rails.json

    {
      "name": "rails",
      "downloads": 7528417,
      "version": "3.2.1",
      "version_downloads": 47602,
      "authors": "David Heinemeier Hansson",
      "info": "Ruby on Rails is a full-stack web framework optimized for programmer
              happiness and sustainable productivity. It encourages beautiful code
              by favoring convention over configuration.",
      "project_uri": "http://rubygems.org/gems/rails",
      "gem_uri": "http://rubygems.org/gems/rails-3.2.1.gem",
      "homepage_uri": "http://www.rubyonrails.org",
      "wiki_uri": "http://wiki.rubyonrails.org",
      "documentation_uri": "http://api.rubyonrails.org",
      "mailing_list_uri": "http://groups.google.com/group/rubyonrails-talk",
      "source_code_uri": "http://github.com/rails/rails",
      "bug_tracker_uri": "http://github.com/rails/rails/issues",
      "dependencies": {
        "development": [],
        "runtime": [
          {
            "name": "actionmailer",
            "requirements":"= 3.2.1"
          },
          {
            "name": "actionpack",
            "requirements": "= 3.2.1"
          },
          {
            "name": "activerecord",
            "requirements": "= 3.2.1"
          },
          {
            "name": "activeresource",
            "requirements": "= 3.2.1"
          },
          {
            "name": "activesupport",
            "requirements": "= 3.2.1"
          },
          {
            "name": "bundler",
            "requirements": "~> 1.0"
          },
          {
            "name": "railties",
            "requirements": "= 3.2.1"
          }
        ]
      }
    }
    }

### GET - `/api/v1/search.(json|yaml)?query=[YOUR QUERY]`

Submit a search to Gemcutter for active gems, just like a search query on the
site. Returns an array of the JSON or YAML representation of gems that match.

    $ curl 'https://rubygems.org/api/v1/search.json?query=cucumber'

    $ curl 'https://rubygems.org/api/v1/search.yaml?query=cucumber'

The results are paginated so the API call will return only the first 30 matched
gems. To get subsequent results, use the page query parameter until an empty
response is received.

    $ curl 'https://rubygems.org/api/v1/search.json?query=cucumber&page=2'

### GET - `/api/v1/gems.(json|yaml)`

List all gems that you own. Returns an array of the JSON or YAML representation
of gems you own.

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
              https://rubygems.org/api/v1/gems.json


### POST - `/api/v1/gems`

Submit a gem to RubyGems.org. Must post a built RubyGem in the request body.

    $ curl --data-binary @gemcutter-0.2.1.gem \
           -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           https://rubygems.org/api/v1/gems

    Successfully registered gem: gemcutter (0.2.1)

### DELETE - `/api/v1/gems/yank`

Remove a gem from RubyGems.org's index. Platform is optional.

    $ curl -X DELETE -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -d 'gem_name=bills' -d 'version=0.0.1' \
           -d 'platform=x86-darwin-10' \
           https://rubygems.org/api/v1/gems/yank

    Successfully yanked gem: bills (0.0.1)


### PUT - `/api/v1/gems/unyank`

Update a previously yanked gem back into RubyGems.org's index. Platform is optional.

    $ curl -X PUT -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -d 'gem_name=bills' -d 'version=0.0.1' \
           -d 'platform=x86-darwin-10' \
           https://rubygems.org/api/v1/gems/unyank

    Successfully unyanked gem: bills (0.0.1)

### GET - `/api/v1/gems/[GEM NAME]/reverse_dependencies.json`

List gems that depends on specified gem. This is all the dependents of particular gem.
Returns an array that includes names of dependent gems.

    $ curl https://rubygems.org/api/v1/gems/shoulda/reverse_dependencies.json

    [
      "jeweler",
      "rubigen",
      "verhoeff",
      "vanilla",
      "soup",
      ...
    ]

Gem Version Methods
-------------------

### GET - `/api/v1/versions/[GEM NAME].(json|yaml)`

Returns an array of gem version details like the below:

    $ curl https://rubygems.org/api/v1/versions/coulda.json

    [
      {
        "authors" : "Evan David Light",
        "built_at" : "2011-08-08T04:00:00.000Z",
        "description" : "Behaviour Driven Development derived from Cucumber but as an internal DSL with methods for reuse",
        "downloads_count" : 2224,
        "number" : "0.7.1",
        "summary" : "Test::Unit-based acceptance testing DSL",
        "platform" : "ruby",
        "ruby_version" : nil,
        "prerelease" : false,
        "licenses" : nil,
        "requirements" : nil,
        "sha" : "777c3a7ed83e44198b0a624976ec99822eb6f4a44bf1513eafbc7c13997cd86c"
      }
    ]

### GET - `/api/v1/versions/[GEM NAME]/latest.json`

Returns an object containing the latest version of particular gem.

    $ curl https://rubygems.org/api/v1/versions/rails/latest.json

    {
      "version": "4.2.1"
    }

Gem Download Methods
--------------------

### GET - `/api/v1/downloads.(json|yaml)`

Returns an object containing the total number of downloads on RubyGems.

    $ curl https://rubygems.org/api/v1/downloads.json

    {
      "total": 461672727
    }

### GET - `/api/v1/downloads/[GEM NAME]-[GEM VERSION].(json|yaml)`

Returns an object containing the total number of downloads for a particular gem
as well as the total number of downloads for the specified version.

    $ curl https://rubygems.org/api/v1/downloads/rails_admin-0.0.0.json

    {
      "version_downloads": 3142,
      "total_downloads": 3142
    }

Owner Methods
-------------

### GET - `/api/v1/owners/[USER HANDLE]/gems.(json|yaml)`

View all gems for a user. This is all the gems a user can push to.

    $ curl https://rubygems.org/api/v1/owners/qrush/gems.json

    [
      {
        "name": "factory_girl",
    ...
      },
    ...
    ]


### GET - `/api/v1/gems/[GEM NAME]/owners.(json|yaml)`

View all owners of a gem. These users can all push to this gem.

    $ curl https://rubygems.org/api/v1/gems/gemcutter/owners.json

    [
      {
        "email": "nick@gemcutter.org"
      },
      {
        "email": "ddollar@gmail.com"
      }
    ]

### POST - `/api/v1/gems/[GEM NAME]/owners`

Add an owner to a RubyGem you own, giving that user permission to manage it.

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -F 'email=josh@technicalpickles.com' \
           https://rubygems.org/api/v1/gems/gemcutter/owners

    Owner added successfully.

### DELETE - `/api/v1/gems/[GEM NAME]/owners`

Remove a user's permission to manage a RubyGem you own.

    $ curl -X DELETE -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
            -d "email=josh@technicalpickles.com" \
            https://rubygems.org/api/v1/gems/gemcutter/owners

    Owner removed successfully.

WebHook Methods
---------------

### GET - `/api/v1/web_hooks.(json|yaml)`

List the webhooks registered under your account.

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           https://rubygems.org/api/v1/web_hooks.json

    {
      "all gems": [
        {
          "url": "http://gemwhisperer.heroku.com",
          "failure_count": 1
        }
      ],
      "rails": [
        {
          "url": "http://example.com",
          "failure_count": 0
        }
      ]
    }

### POST - `/api/v1/web_hooks`

Create a webhook. Requires two parameters: `gem_name` and `url`. Specify `*`
for the `gem_name` parameter to apply the hook globally to all gems.

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -F 'gem_name=rails' -F 'url=http://example.com' \
           https://rubygems.org/api/v1/web_hooks

    Successfully created webhook for rails to http://example.com

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -F 'gem_name=*' -F 'url=http://example.com' \
           https://rubygems.org/api/v1/web_hooks

    Successfully created webhook for all gems to http://example.com

### DELETE - `/api/v1/web_hooks/remove`

Remove a webhook. Requires two parameters: `gem_name` and `url`. Specify `*`
for the `gem_name` parameter to apply the hook globally to all gems.

    $ curl -X DELETE -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -d 'gem_name=rails' -d 'url=http://example.com' \
           https://rubygems.org/api/v1/web_hooks/remove

    Successfully removed webhook for rails to http://example.com

    $ curl -X DELETE -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -d 'gem_name=*' -d 'url=http://example.com' \
           https://rubygems.org/api/v1/web_hooks/remove

    Successfully removed webhook for all gems to http://example.com

### POST - `/api/v1/web_hooks/fire`

Test fire a webhook. This can be used to test out an endpoint at any time, for
example when you're developing your application. Requires two parameters:
`gem_name` and `url`. Specify `*` for the gem_name parameter to apply the hook
globally to all gems.

An `Authorization` header is included with every fired webhook so you can be
sure the request came from RubyGems.org. The value of the header is the
SHA2-hashed concatenation of the gem name, the gem version and your API key.

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -F 'gem_name=rails' -F 'url=http://example.com' \
           https://rubygems.org/api/v1/web_hooks/fire

    Successfully deployed webhook for rails to http://example.com

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -F 'gem_name=*' -F 'url=http://example.com' \
           https://rubygems.org/api/v1/web_hooks/fire

    Successfully deployed webhook for all gems to http://example.com

Activity Methods
------------

### GET - `/api/v1/activity/latest`

Pulls the 50 gems most recently added to RubyGems.org (for the first time). Returns an array of the JSON or YAML representation of the gems.

    $ curl 'https://rubygems.org/api/v1/activity/latest.json'

### GET - `/api/v1/activity/just_updated`

Pulls the 50 most recently updated gems. Returns an array of the JSON or YAML representation of the gem versions.

    $ curl 'https://rubygems.org/api/v1/activity/just_updated.json'

Misc Methods
------------

### GET - `/api/v1/api_key.(json|yaml)`

Retrieve your API key using HTTP basic auth.

    $ curl -u "nick@gemcutter.org:schwwwwing" \
           https://rubygems.org/api/v1/api_key.json

    {
      "rubygems_api_key": "701243f217cdf23b1370c7b66b65ca97"
    }

### GET - `/api/v1/dependencies?gems=[COMMA DELIMITED GEM NAMES]`

Returns a marshalled array of hashes for all versions of given gems. Each hash
contains a gem version with its dependencies making this useful for resolving dependencies.

    $ ruby -ropen-uri -rpp -e \
      'pp Marshal.load(open("https://rubygems.org/api/v1/dependencies?gems=rails,thor"))'

    [{:platform=>"ruby",
      :dependencies=>
       [["bundler", "~> 1.0"],
        ["railties", "= 3.0.3"],
        ["actionmailer", "= 3.0.3"],
        ["activeresource", "= 3.0.3"],
        ["activerecord", "= 3.0.3"],
        ["actionpack", "= 3.0.3"],
        ["activesupport", "= 3.0.3"]],
      :name=>"rails",
      :number=>"3.0.3"},
    ...
    {:number=>"0.9.9", :platform=>"ruby", :dependencies=>[], :name=>"thor"}]
