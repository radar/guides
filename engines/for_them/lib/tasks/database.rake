require 'active_support/all'
require 'active_record'

ActiveRecord::Base.establish_connection(YAML.load_file(File.expand_path("../../../config/database.yml", __FILE__)))

namespace :db do
  task :migrate do
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_path, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end
  
  task :rollback do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_path, step)
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end
  
  namespace :schema do
    desc "Create a db/schema.rb file that can be portably used against any DB supported by AR"
    task :dump do
      require 'active_record/schema_dumper'
      File.open(ENV['SCHEMA'] || "db/schema.rb", "w") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
      Rake::Task["db:schema:dump"].reenable
    end

    desc "Load a schema.rb file into the database"
    task :load do
      file = ENV['SCHEMA'] || "db/schema.rb"
      if File.exists?(file)
        load(file)
      else
        abort %{#{file} doesn't exist yet. Run "rake db:migrate" to create it then try again.}
      end
    end
  end
end