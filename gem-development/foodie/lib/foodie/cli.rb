require 'thor'
require 'foodie'

require 'foodie/generators/recipe'

module Foodie
  class CLI < Thor
    desc "portray ITEM", "Determines if a piece of food is gross or delicious"
    def portray(name)
      puts Foodie::Food.portray(name)
    end
    
    desc "pluralize", "Pluralizes a word"
    method_option :word, :aliases => :word
    def pluralize
      puts Foodie::Food.pluralize(options[:word])
    end
    
    desc "recipe", "Generates a recipe scaffold"
    def recipe(group, name)
      Foodie::Generators::Recipe.start([group, name])
    end
  end
end
