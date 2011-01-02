require 'by_star'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", 
                                        :database => File.dirname(__FILE__) + "/by_star.sqlite3")

load File.dirname(__FILE__) + '/support/schema.rb'
load File.dirname(__FILE__) + '/support/models.rb'
load File.dirname(__FILE__) + '/support/data.rb'