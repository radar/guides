---
layout: default
title: RubyGems.org API
previous: /specification-reference
next: /run-your-own-gem-server
---

{% include big.html %}

How to interact with RubyGems.org over HTTP.

The API is a work in progress, and [can use your
help!](http://github.com/rubygems/gemcutter) RubyGems itself and the
[gemcutter gem](http://rubygems.org/gems/gemcutter) uses the API to push gems,
add owners, and more.

* [Gem Methods](#gem): Query or create rubygems to be hosted
* [Gem Version Methods](#gemversion): Query for information about versions of a particular ruby gem
* [Gem Version Download Methods](#gemversiondownloads): for download statistics about a particular ruby gem version
* [Owner Methods](#owner): Manage owners for gems
* [Webhook Methods](#webhook): Manage notifications for when gems are pushed
* [Misc Methods](#misc): Various other interactions with the site

<a id="gem"> </a>
Gem Methods
-----------

### GET - `/api/v1/gems/[name].(json|xml)`

Returns some basic information about the given gem. For example, here's Rails in JSON:

    $ curl http://rubygems.org/api/v1/gems/rails.json

    {
      "name": "rails",
      "info": "Rails is a framework for building web-application using CGI, FCGI, mod_ruby,
               or WEBrick on top of either MySQL, PostgreSQL, SQLite, DB2, SQL Server, or 
               Oracle with eRuby- or Builder-based templates.",
      "version": "2.3.5",
      "version_downloads": 2451,
      "authors": "David Heinemeier Hansson",
      "downloads": 134451,
      "project_uri": "http://rubygems.org/gems/rails",
      "gem_uri": "http://rubygems.org/gems/rails-2.3.5.gem",
      "homepage_uri": "http://www.rubyonrails.org/",
      "wiki_uri": "http://wiki.rubyonrails.org/",
      "documentation_uri": "http://api.rubyonrails.org/",
      "mailing_list_uri": "http://groups.google.com/group/rubyonrails-talk",
      "source_code_uri": "http://github.com/rails/rails",
      "bug_tracker_uri": "http://rails.lighthouseapp.com/projects/8994-ruby-on-rails",
      "dependencies": {
        "runtime": [
          {
            "name": "activesupport",
            "requirements": ">= 2.3.5"
          }
        ],
        "development": [ ]
      }
    }

or XML:

    $ curl http://rubygems.org/api/v1/gems/rails.xml

    <?xml version="1.0" encoding="UTF-8"?>
    <rubygem>
      <downloads type="integer">223423</downloads>
      <name>rails</name>
      <info>
        Rails is a framework for building web-application using CGI, FCGI, mod_ruby, or
        WEBrick on top of either MySQL, PostgreSQL, SQLite, DB2, SQL Server, or Oracle
        with eRuby- or Builder-based templates.
      </info>
      <gem-uri>http://rubygems.org/gems/rails-2.3.5.gem</gem-uri>
      <project-uri>http://rubygems.org/gems/rails</project-uri>
      <version>2.3.5</version>
      <authors>David Heinemeier Hansson</authors>
      <version-downloads type="integer">141363</version-downloads>
      <homepage-uri>http://www.rubyonrails.org/</homepage-uri>
      <wiki-uri>http://wiki.rubyonrails.org/</wiki-uri>
      <documentation-uri>http://api.rubyonrails.org/</documentation-uri>
      <mailing-list-uri>http://groups.google.com/group/rubyonrails-talk</mailing-list-uri>
      <source-code-uri>http://github.com/rails/rails</source-code-uri>
      <bug-tracker-uri>http://rails.lighthouseapp.com/projects/8994-ruby-on-rails</bug-tracker-uri>
      <dependencies>
        <development type="array"/>
        <runtime type="array">
          <dependency>
            <name>activesupport</name>
            <requirements>>= 2.3.5</requirements>
          </dependency>
        </runtime>
      </dependencies>
    </rubygem>

### GET - `/api/v1/search.(json|xml)?query=[YOUR QUERY]`

Submit a search to Gemcutter for active gems, just like a search query on the site. Returns an array of the XML or JSON representation of gems that match.

    $ curl 'http://rubygems.org/api/v1/search.json?query=cucumber'

    $ curl 'http://rubygems.org/api/v1/search.xml?query=cucumber'

### GET - `/api/v1/gems.(json|xml)`

List all gems that you own. Returns an array of the XML or JSON representation of gems you own.

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
              http://rubygems.org/api/v1/gems.json


### POST - `/api/v1/gems`

Submit a gem to RubyGems.org. Must have your API key supplied and give a built RubyGem in the body of the request.

    $ curl --data-binary @gemcutter-0.2.1.gem \
           -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           http://rubygems.org/api/v1/gems

    Successfully registered gem: gemcutter (0.2.1)

### DELETE - `/api/v1/gems/yank`

Remove a gem from RubyGems.org's index. Platform is optional.

    $ curl -X DELETE -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -d 'gem_name=bills' -d 'version=0.0.1' \
           -d 'platform=x86-darwin-10' \
           http://rubygems.org/api/v1/gems/yank

    Successfully yanked gem: bills (0.0.1)


### PUT - `/api/v1/gems/unyank`

Update a previously yanked gem back into RubyGems.org's index. Platform is optional.

    $ curl -X PUT -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -d 'gem_name=bills' -d 'version=0.0.1' \
           -d 'platform=x86-darwin-10' \
           http://rubygems.org/api/v1/gems/unyank

    Successfully unyanked gem: bills (0.0.1)

<a id="gemversion"> </a>
Gem Version Methods
-------------------

### GET - `/api/v1/versions/[rubygem name].json`

Returns a JSON array of gem version details like the below:

    $ curl http://rubygems.org/api/v1/versions/coulda.json

    [
       {
          "number" : "0.6.3",
          "built_at" : "2010-12-23T05:00:00Z",
          "summary" : "Test::Unit-based acceptance testing DSL",
          "downloads_count" : 175,
          "platform" : "ruby",
          "authors" : "Evan David Light",
          "description" : "Behaviour Driven Development derived from Cucumber but
                           as an internal DSL with methods for reuse",
          "prerelease" : false,
       }
    ]

<a id="gemversiondownloads"> </a>
Gem Version Download Methods
----------------------------

### GET - `/api/v1/versions/[rubygem name]-[rubygem version]/downloads.json`

Returns a JSON object containing the number of downloads by day for a particular gem version for 90 days of data. 

    $ curl http://rubygems.org/api/v1/versions/coulda-0.6.3/downloads.json

    {
      "2010-11-30":0,
      "2010-12-01":0,
      "2010-12-02":0,
      ...
    }

### GET - `/api/v1/versions/[rubygem name]-[rubygem version]/downloads/search.json?from=[start date str]&to=[end date str]`

Returns a JSON object containing the number of downloads by day for a particular gem version for 90 days of data.

    $ curl http://rubygems.org/api/v1/versions/coulda-0.6.3/downloads/search.json?from=2011-11-1&to=2011-11-5</h5>

    {
      "2011-11-01":0,
      "2011-11-02":0,
      "2011-11-03":0,
      "2011-11-04":0,
      "2011-11-05":0
    }

<a id="owner"> </a>
Owner Methods
-------------

### GET - `/api/v1/gems/[rubygem name]/owners.json`

View all owners of a gem that you own. These users can all push to this gem.

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           http://rubygems.org/api/v1/gems/gemcutter/owners.json

    [
      {
        "email": "nick@gemcutter.org"
      },
      {
        "email": "ddollar@gmail.com"
      }
    ]

### POST - `/api/v1/gems/[rubygem name]/owners`

Add an owner to a RubyGem you own, giving that user permission to manage it.

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -F 'email=josh@technicalpickles.com' \
           http://rubygems.org/api/v1/gems/gemcutter/owners

    Owner added successfully.

### DELETE - `/api/v1/gems/[rubygem name]/owners`

Remove a user's permission to manage a RubyGem you own.

    $ curl -X DELETE -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
            -d "email=josh@technicalpickles.com" \
            http://rubygems.org/api/v1/gems/gemcutter/owners

    Owner removed successfully.

<a id="webhook"> </a>
WebHook Methods
---------------

### GET - `/api/v1/web_hooks.json`

List the webhooks registered under your account.

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           http://rubygems.org/api/v1/web_hooks.json

    {
      "all gems": [
        {
          "url": "http://gemwhisperer.heroku.com",
          "failure_count": 1
        }
      ]
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
           http://rubygems.org/api/v1/web_hooks

    Successfully created webhook for rails to http://example.com

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -F 'gem_name=*' -F 'url=http://example.com' \
           http://rubygems.org/api/v1/web_hooks

    Successfully created webhook for all gems to http://example.com

### DELETE - `/api/v1/web_hooks/remove`

Remove a webhook. Requires two parameters: `gem_name` and `url`. Specify `*`
for the `gem_name` parameter to apply the hook globally to all gems.

    $ curl -X DELETE -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -d 'gem_name=rails' -d 'url=http://example.com' \
           http://rubygems.org/api/v1/web_hooks/remove

    Successfully removed webhook for rails to http://example.com

    $ curl -X DELETE -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -d 'gem_name=*' -d 'url=http://example.com' \
           http://rubygems.org/api/v1/web_hooks/remove

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
           http://rubygems.org/api/v1/web_hooks/fire

    Successfully deployed webhook for rails to http://example.com

    $ curl -H 'Authorization:701243f217cdf23b1370c7b66b65ca97' \
           -F 'gem_name=*' -F 'url=http://example.com' \
           http://rubygems.org/api/v1/web_hooks/fire

    Successfully deployed webhook for all gems to http://example.com

<a id="misc"> </a>
Misc Methods
------------

### GET - `/api/v1/api_key`

Retrieve your API key using HTTP basic auth.

    $ curl -u "nick@gemcutter.org:schwwwwing" \
           http://rubygems.org/api/v1/api_key

    701243f217cdf23b1370c7b66b65ca97

### GET - `/api/v1/dependencies?gems=[comma delimited rubygems]`

Returns a marshalled array of hashes for all versions of given gems. Each hash
contains a gem version with its dependencies making this useful for resolving dependencies.

    $ ruby -ropen-uri -rpp -e \
      'pp Marshal.load(open("http://rubygems.org/api/v1/dependencies?gems=rails,thor"))'

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
