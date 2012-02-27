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

  erbio = RDoc::ERBIO.new File.read("command-reference.erb"), nil, nil
  open 'command-reference.md', 'w' do |io|
    erbio.result binding
  end
end
