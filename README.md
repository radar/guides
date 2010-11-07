# The Ruby Ecosystem Guides

Thanks for visiting! This is my (currently little) repository containing my guides about how to work with various tools in the Ruby Ecosystem.

There's currently only one guide: "Developing a RubyGem using Bundler". It teaches you how to develop a gem using Bundler, testing things such as methods and command-line interfaces. If you're thinking of developing your own gem then this is the perfect place to start.

I'm currently in the planning stages of the second guide: "Writing a Rails 3 Engine" which will be a chapter in the book I am co-authoring with [Yehuda Katz](http://yehudakatz.com) called [Rails 3 in Action](http://manning.com/katz) as well as freely available here as a form of promotion for the book.

## You made a mistake! / I don't understand!

Please file an [issue](http://github.com/radar/guides/issues) and I'll see what I can do about it. If you don't understand something then I'm Doing It Wrong.

## A bit of background

It's no secret: I *love* writing and I *love love* Ruby. So why not combine the two? That's how this repository got started.

I discovered the `bundle gem` command whilst skimming the [CHANGELOG for Bundler](http://github.com/carlhuda/bundler/blob/master/CHANGELOG.md). It was added in 1.0.0.rc4, the third-to-last RC before Bundler's 1.0.0 release and I was instantly in love with it. I moved my [by_star](http://github.com/radar/by_star) and [lookup](http://github.com/radar/lookup) gems across to it and then I got interested as to how I would go about developing a brand-new gem using Bundler, Thor, RSpec and Cucumber. So that's what I did, documenting the whole process as the "Developing a RubyGem using Bundler" guide.

The upcoming engines guide was a result of a couple of polls I put out on [Twitter](http://ryanbigg.com). There's a massive void of nothingness where there should be documentation about developing engines in Rails 3 which I hope to fix with this guide.

## Who would do such a thing?!

[I](http://ryanbigg.com) would do. By writing about how to use a tool, I gain a better understanding of how it works and get to share that knowledge with the rest of the world. I do all of this on my own personal time as a way to promote myself as a Smart Kinda Guy, and also to share what I know with the rest of the world just in case there's an unfortunate moment where I'm unable to from then on.

Whilst writing and researching all these things _can_ be frustrating at some points, I do it because of the high I get when I figure something out.

If you'd like to help out, please buy a copy of [Rails 3 in Action](http://manning.com/katz). This puts money in my pocket which I can then use to put food on my table which I put in my mouth to power my brain and fingers to write more guides.

## Helper-outerers

Andre Arko: Discussion about where to put the development dependencies for the "Developing a RubyGem using Bundler" guide. They should go in the _.gemspec_ file by using the `add_development_dependency` method.