# -*- encoding: utf-8 -*-
require File.expand_path("../lib/by_star/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "by_star"
  s.version     = ByStar::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = []
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/by_star"
  s.summary     = "TODO: Write a gem summary"
  s.description = "TODO: Write a gem description"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "by_star"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", "~> 2.3"
  s.add_development_dependency "sqlite3-ruby"
  
  s.add_dependency "activerecord", "~> 3.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
