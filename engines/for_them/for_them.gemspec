# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "for_them"
  s.summary = "Insert ForThem summary."
  s.description = "Insert ForThem description."
  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.version = "0.0.1"
  
  s.add_development_dependency "cucumber-rails"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "sqlite3-ruby"
  s.add_development_dependency "rails"
  s.add_development_dependency "capybara"
end