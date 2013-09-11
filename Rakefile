gem "rdoc"

require 'rdoc/rdoc'
require 'rdoc/task'
require 'fileutils'

$:.unshift '.', '../rubygems/lib'

ENV['RUBYGEMS_DIR'] ||= File.expand_path '../../rubygems', __FILE__

task :RUBYGEMS_DIR_exists do
  message = <<-NO_RUBYGEMS_DIR
The Rubygems rdocs are required to build the spec guide.

Install or clone it from GitHub, then:

    RUBYGEMS_DIR=/path/to/rubygems/source rake spec_guide --trace

The RUBYGEMS_DIR is assumed to exist at:

    #{ENV['RUBYGEMS_DIR']}
  NO_RUBYGEMS_DIR

  abort message unless File.exist? ENV['RUBYGEMS_DIR']
end

# RUBYGEMS_DIR should be checked first
task rdoc_spec: %w[RUBYGEMS_DIR_exists]

RDoc::Task.new(:rdoc_spec) do |rd|
  spec_file = File.join(ENV["RUBYGEMS_DIR"].to_s, "lib", "rubygems", "specification.rb")
  rd.rdoc_files.include(spec_file)
  rd.template = "jekdoc"
end

desc "move spec guide into the right place"
task :move_spec => [:rdoc_spec] do
  FileUtils.mv "html/Gem/Specification.html", "specification-reference.md"
end

desc "clean up after rdoc"
task :clean do
  FileUtils.rm_rf "html"
end

desc "generate specification guide"
task :spec_guide => [:rdoc_spec, :move_spec, :clean]

desc "generate command guide"
task :command_guide => %w[command-reference.md]

command_reference_files = Rake::FileList.new(*%W[
  #{__FILE__}
  ../rubygems/lib/rubygems.rb
  ../rubygems/lib/rubygems/command_manager.rb
  ../rubygems/lib/rubygems/commands/*.rb
])

file 'command-reference.md' => command_reference_files do
  require 'rubygems/command_manager'
  require 'rdoc/erbio'

  rubygems_version = Gem.rubygems_version.version
  names    = Gem::CommandManager.instance.command_names
  commands = {}
  names.each do |name|
    command = Gem::CommandManager.instance[name]
    command.options[:help] = ''
    commands[name] = command
  end

  def htmlify(string)
    lines = string.split("\n")
    html_string = ''
    lines.each do |line|
      if line
        if line =~ /^  /
          # This will end up in a <pre> block
          html_string += line
        else
          puts html_string
          html_string += line.gsub("<", "&lt;").gsub(">", "&gt;")
          puts html_string
        end
        html_string += "\n"
      end
    end
    html_string[0..-2]
  end

  def argument_list_item(string)
    if string =~ /^(\S+)(.*)/
      string = "*#{$1}* - #{$2}"
    end
    htmlify("* #{string}")
  end

  def options_list(command)
    # Invoke the Ruby options parser by asking for help. Otherwise the options
    # list in the parser will never be initialized.
    # TODO: Figure out how to avoid dumping help to stdout when running this rake task
    command.show_help
    parser = command.send(:parser)
    options = ''
    helplines = parser.summarize
    helplines.each do |helpline|
      break if (helpline =~ /Arguments/) || (helpline =~  /Summary/)
      unless helpline.gsub(/\n/, '').strip == ''
        # Use zero-width space to prevent "helpful" change of -- to &ndash;
        helpline = helpline.gsub('--', '-&#8203;-').gsub('[', '\\[').gsub(']', '\\]')

        if helpline =~ /^\s{10,}(.*)/
          options = options[0..-2] + " #{$1}\n"
        else
          if helpline =~ /^(.*)\s{3,}(.*)/
            helpline = "#{$1} - #{$2}"
          end
          if helpline =~ /options/i
            options += "\n### #{helpline}\n"
          else
            options += "* #{helpline}\n"
          end
        end
      end
    end
    options
  end

  filename = "command-reference.erb"

  erbio = RDoc::ERBIO.new File.read(filename), nil, nil
  erbio.filename = filename

  open 'command-reference.md', 'w' do |io|
    erbio.result binding
  end
end

desc "serve documentation on http://localhost:4000"
task :server do
  pids = [
    spawn('jekyll', '--server', '4000'),
    spawn('scss', '--watch', 'stylesheets:stylesheets'),
  ]

  trap "INT" do
    Process.kill "INT", *pids
    exit 1
  end

  trap "TERM" do
    Process.kill "TERM", *pids
    exit 1
  end

  pids.each do |pid|
    Process.waitpid pid
  end
end

desc 'build documentation and display it on http://localhost:4000'
task default: %w[spec_guide command_guide server]

