---
layout: default
title: Specification Reference
previous: /command-reference
next: /rubygems-org-api
---

{% include big.html %}


<p>The <a href="Specification.html">Specification</a> class contains the
metadata for a <a href="../Gem.html">Gem</a>.  Typically defined in a
.gemspec file or a Rakefile, and looks like this:</p>

<pre>Gem::Specification.new do |s|
  s.name        = 'example'
  s.version     = '0.1.0'
  s.date        = '2011-05-17'
  s.summary     = &quot;This is an example!&quot;
  s.description = &quot;Much longer explanation of the example!&quot;
  s.authors     = [&quot;Ruby Coder&quot;]
  s.email       = 'rubycoder@example.com'
  s.files       = [&quot;lib/example.rb&quot;]
  s.homepage    = 'http://rubygems.org/gems/example'
end</pre>

  
  
  
  

  
  
    
  
    
  
    
  
    
  
    
  
  
    
      
    
      
    
      
    
  
    
      
        
      
        
      
    
      
    
      
    
  
  
  
    
  
    
  
    
  
    
  
    
  
    
  
    
  
  
    
      
    
      
    
      
    
  
    
      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
    
      
    
      
    
  

## Required gemspec attributes
    
* [files](#files)
    
* [name](#name)
    
* [platform=](#platform=)
    
* [require_paths](#require_paths)
    
* [rubygems_version](#rubygems_version)
    
* [summary](#summary)
    
* [version](#version)
    
## Optional gemspec attributes
    
* [add_development_dependency](#add_development_dependency)
    
* [add_runtime_dependency](#add_runtime_dependency)
    
* [author=](#author=)
    
* [authors=](#authors=)
    
* [bindir](#bindir)
    
* [cert_chain](#cert_chain)
    
* [description](#description)
    
* [email](#email)
    
* [executables](#executables)
    
* [extensions](#extensions)
    
* [extra_rdoc_files](#extra_rdoc_files)
    
* [homepage](#homepage)
    
* [license=](#license=)
    
* [licenses=](#licenses=)
    
* [post_install_message](#post_install_message)
    
* [rdoc_options](#rdoc_options)
    
* [required_ruby_version=](#required_ruby_version=)
    
* [requirements](#requirements)
    
* [signing_key](#signing_key)
    
* [test_files=](#test_files=)
    


# Required gemspec attributes


    

<a id="files"> </a>
## files

<p>Files included in this gem.  You cannot append to this accessor, you must
assign to it.</p>

<p>Only add files you can require to this list, not directories, etc.</p>

<p>Directories are automatically stripped from this list when building a gem,
other non-files cause an error.</p>

<p>Usage:</p>

<pre>require 'rake'
spec.files = FileList['lib/**/*.rb',
                      'bin/*',
                      '[A-Z]*',
                      'test/**/*'].to_a

# or without Rake...
spec.files = Dir['lib/**/*.rb'] + Dir['bin/*']
spec.files += Dir['[A-Z]*'] + Dir['test/**/*']
spec.files.reject! { |fn| fn.include? &quot;CVS&quot; }</pre>    

<a id="name"> </a>
## name

<p>This gem’s name.</p>

<p>Usage:</p>

<pre>spec.name = 'rake'</pre>    

<a id="platform="> </a>
## platform=

<p>The platform this gem runs on.</p>

<p>This is usually Gem::Platform::RUBY or Gem::Platform::CURRENT.</p>

<p>Most gems contain pure Ruby code; they should simply leave the default
value in place. Some gems contain C (or other) code to be compiled into a
Ruby “extension”. The should leave the default value in place unless their
code will only compile on a certain type of system. Some gems consist of
pre-compiled code (“binary gems”). It’s especially important that they set
the platform attribute appropriately. A shortcut is to set the platform to
Gem::Platform::CURRENT, which will cause the gem builder to set the
platform to the appropriate value for the system on which the build is
being performed.</p>

<p>If this attribute is set to a non-default value, it will be included in the
filename of the gem when it is built, e.g. fxruby-1.2.0-win32.gem.</p>

<p>Usage:</p>

<pre>spec.platform = Gem::Platform::Win32</pre>    

<a id="require_paths"> </a>
## require_paths

<p>Paths in the gem to add to <tt>$LOAD_PATH</tt> when this gem is activated.</p>

<p>Usage:</p>

<pre># If all library files are in the root directory...
spec.require_path = '.'

# If you have 'lib' and 'ext' directories...
spec.require_paths &lt;&lt; 'ext'</pre>    

<a id="rubygems_version"> </a>
## rubygems_version

<p>The version of RubyGems used to create this gem.</p>

<p>Do not set this, it is set automatically when the gem is packaged.</p>    

<a id="summary"> </a>
## summary

<p>A short summary of this gem’s description.  Displayed in `gem list -d`.</p>

<p>The description should be more detailed than the summary.</p>

<p>Usage:</p>

<pre>spec.summary = &quot;This is a small summary of my gem&quot;</pre>    

<a id="version"> </a>
## version

<p>This gem’s version.</p>

<p>The version string can contain numbers and periods, such as <tt>1.0.0</tt>.
A gem is a ‘prerelease’ gem if the version has a letter in it, such as
<tt>1.0.0.pre</tt>.</p>

<p>Usage:</p>

<pre>spec.version = '0.4.1'</pre>    

# Optional gemspec attributes


    

<a id="add_development_dependency"> </a>
## add_development_dependency

<p>Adds a development dependency named <tt>gem</tt> with <tt>requirements</tt>
to this gem.</p>

<p>Usage:</p>

<pre>spec.add_development_dependency 'example', '~&gt; 1.1', '&gt;= 1.1.4'</pre>

<p>Development dependencies aren’t installed by default and aren’t activated
when a gem is required.</p>    

<a id="add_runtime_dependency"> </a>
## add_runtime_dependency

<p>Adds a runtime dependency named <tt>gem</tt> with <tt>requirements</tt> to
this gem.</p>

<p>Usage:</p>

<pre>spec.add_runtime_dependency 'example', '~&gt; 1.1', '&gt;= 1.1.4'</pre>    

<a id="author="> </a>
## author=

<p>Singular writer for <a
href="Specification.html#method-i-authors">authors</a></p>

<p>Usage:</p>

<pre>spec.author = 'John Jones'</pre>    

<a id="authors="> </a>
## authors=

<p>Sets the list of authors, ensuring it is an array.</p>

<p>Usage:</p>

<pre>spec.authors = ['John Jones', 'Mary Smith']</pre>    

<a id="bindir"> </a>
## bindir

<p>The path in the gem for executable scripts.  Usually ‘bin’</p>

<p>Usage:</p>

<pre>spec.bindir = 'bin'</pre>    

<a id="cert_chain"> </a>
## cert_chain

<p>The certificate chain used to sign this gem.  See Gem::Security for
details.</p>    

<a id="description"> </a>
## description

<p>A long description of this gem</p>

<p>The description should be more detailed than the summary.</p>

<p>Usage:</p>

<pre>spec.description = &lt;&lt;-EOF
  Rake is a Make-like program implemented in Ruby. Tasks and
  dependencies are specified in standard Ruby syntax.
EOF</pre>    

<a id="email"> </a>
## email

<p>A contact email for this gem</p>

<p>Usage:</p>

<pre>spec.email = 'john.jones@example.com'
spec.email = ['jack@example.com', 'jill@example.com']</pre>    

<a id="executables"> </a>
## executables

<p>Executables included in the gem.</p>

<p>For example, the rake gem has rake as an executable. You don’t specify the
full path (as in bin/rake); all application-style files are expected to be
found in bindir.</p>

<p>Usage:</p>

<pre>spec.executables &lt;&lt; 'rake'</pre>    

<a id="extensions"> </a>
## extensions

<p>Extensions to build when installing the gem, specifically the paths to
extconf.rb-style files used to compile extensions.</p>

<p>These files will be run when the gem is installed, causing the C (or
whatever) code to be compiled on the user’s machine.</p>

<p>Usage:</p>

<pre>spec.extensions &lt;&lt; 'ext/rmagic/extconf.rb'</pre>    

<a id="extra_rdoc_files"> </a>
## extra_rdoc_files

<p>Extra files to add to RDoc such as README or doc/examples.txt</p>

<p>When the user elects to generate the RDoc documentation for a gem
(typically at install time), all the library files are sent to RDoc for
processing. This option allows you to have some non-code files included for
a more complete set of documentation.</p>

<p>Usage:</p>

<pre>spec.extra_rdoc_files = ['README', 'doc/user-guide.txt']</pre>    

<a id="homepage"> </a>
## homepage

<p>The URL of this gem’s home page</p>

<p>Usage:</p>

<pre>spec.homepage = 'http://rake.rubyforge.org'</pre>    

<a id="license="> </a>
## license=

<p>The license for this gem.</p>

<p>The license must be a short name, no more than 64 characters.</p>

<p>This should just be the name of your license, make to include the full text
of the license inside of the gem when you build it.</p>

<p>Usage:</p>

<pre>spec.license = 'MIT'</pre>    

<a id="licenses="> </a>
## licenses=

<p>The license(s) for the library.</p>

<p>Each license must be a short name, no more than 64 characters.</p>

<p>This should just be the name of your license, make to include the full text
of the license inside of the gem when you build it.</p>

<p>Usage:</p>

<pre>spec.licenses = ['MIT', 'GPL-2']</pre>    

<a id="post_install_message"> </a>
## post_install_message

<p>A message that gets displayed after the gem is installed.</p>

<p>Usage:</p>

<pre>spec.post_install_message = &quot;Thanks for installing!&quot;</pre>    

<a id="rdoc_options"> </a>
## rdoc_options

<p>Specifies the rdoc options to be used when generating API documentation.</p>

<p>Usage:</p>

<pre>spec.rdoc_options &lt;&lt; '--title' &lt;&lt; 'Rake -- Ruby Make' &lt;&lt;
  '--main' &lt;&lt; 'README' &lt;&lt;
  '--line-numbers'</pre>    

<a id="required_ruby_version="> </a>
## required_ruby_version=

<p>The version of ruby required by this gem</p>

<p>Usage:</p>

<pre># If it will work with 1.8.6 or greater...
spec.required_ruby_version = '&gt;= 1.8.6'

# Hopefully by now:
spec.required_ruby_version = '&gt;= 1.9.2'</pre>    

<a id="requirements"> </a>
## requirements

<p>Lists the external (to RubyGems) requirements that must be met for this gem
to work. It’s simply information for the user.</p>

<p>Usage:</p>

<pre>spec.requirements &lt;&lt; 'libmagick, v6.0'
spec.requirements &lt;&lt; 'A good graphics card'</pre>    

<a id="signing_key"> </a>
## signing_key

<p>The key used to sign this gem.  See Gem::Security for details.</p>    

<a id="test_files="> </a>
## test_files=

<p>A collection of unit test files. They will be loaded as unit tests when the
user requests a gem to be unit tested.</p>

<p>Usage:</p>

<pre>spec.test_files = Dir.glob('test/tc_*.rb')
spec.test_files = ['tests/test-suite.rb']</pre>    
