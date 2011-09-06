gem "rdoc"
require 'rdoc/rdoc'
require 'rdoc/task'
require 'fileutils'

$:.unshift "."

RDoc::Task.new(:rdoc_spec) do |rd|
  spec_file = File.join(ENV["RUBYGEMS_DIR"].to_s, "lib", "rubygems", "specification.rb")
  rd.rdoc_files.include(spec_file)
  rd.template = "jekdoc"
end

desc "move spec guide into the right place"
task :move_spec do
  FileUtils.mv "html/Gem/Specification.html", "specification-reference.md"
end

desc "clean up after rdoc"
task :clean do
  FileUtils.rm_rf "html"
end

desc "generate specification guide"
task :spec_guide => [:rdoc_spec, :move_spec, :clean]


desc "generate command guide"
task :command_guide do
  require 'rubygems/command_manager'
  require 'rdoc/erbio'

  names    = Gem::CommandManager.instance.command_names
  commands = {}
  names.each do |name|
    commands[name] = Gem::CommandManager.instance[name]
  end

  def htmlify(string)
    if string
      string.gsub("<", "&lt;").gsub(">", "&gt;")
    else
      ""
    end
  end

  erbio = RDoc::ERBIO.new File.read("command-reference.erb"), nil, nil
  open 'command-reference.md', 'w' do |io|
    erbio.result binding
  end
end
