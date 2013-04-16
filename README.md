# The Ruby Ecosystem Guides

Thanks for visiting! This is my (currently little) repository containing my guides about how to work with various tools in the Ruby Ecosystem.

## You made a mistake! / I don't understand!

Please file an [issue](http://github.com/radar/guides/issues) and I'll see what I can do about it. If you don't understand something then I'm Doing It Wrong.

## A bit of background

It's no secret: I *love* writing and I *love love* Ruby. So why not combine the two? That's how this repository got started.

I discovered the `bundle gem` command whilst skimming the [CHANGELOG for Bundler](http://github.com/carlhuda/bundler/blob/master/CHANGELOG.md). It was added in 1.0.0.rc4, the third-to-last RC before Bundler's 1.0.0 release and I was instantly in love with it. I moved my [by_star](http://github.com/radar/by_star) and [lookup](http://github.com/radar/lookup) gems across to it and then I got interested as to how I would go about developing a brand-new gem using Bundler, Thor, RSpec and Cucumber. So that's what I did, documenting the whole process as the "Developing a RubyGem using Bundler" guide.

## Who would do such a thing?!

[I](http://ryanbigg.com) would do. By writing about how to use a tool, I gain a better understanding of how it works and get to share that knowledge with the rest of the world. I do all of this on my own personal time as a way to promote myself as a Smart Kinda Guy, and also to share what I know with the rest of the world just in case there's an unfortunate moment where I'm unable to from then on.

Whilst writing and researching all these things _can_ be frustrating at some points, I do it because of the high I get when I figure something out.

If you'd like to help out, please buy a copy of [Rails 4 in Action](http://manning.com/bigg2). This puts money in my pocket which I can then use to put food on my table which I put in my mouth to power my brain and fingers to write more guides and books.

## Helper-outerers

Andre Arko: Discussion about where to put the development dependencies for the "Developing a RubyGem using Bundler" guide. They should go in the _.gemspec_ file by using the `add_development_dependency` method.
