# -*- encoding: utf-8 -*-
require File.expand_path("../lib/foodie/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "foodie"
  s.version     = Foodie::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = []
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/foodie"
  s.summary     = "For food"
  s.description = "For food"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "foodie"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", "~> 2.0.0.beta.22"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "aruba"
  
  s.add_dependency "activesupport"
  s.add_dependency "thor"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
