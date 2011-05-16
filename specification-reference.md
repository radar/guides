---
layout: default
title: Specification Reference
previous: /command-reference
next: /rubygems-org-api
---


<p>The <a href="Specification.html">Specification</a> class contains the
metadata for a <a href="../Gem.html">Gem</a>.  Typically defined in a
.gemspec file or a Rakefile, and looks like this:</p>

<pre>spec = Gem::Specification.new do |s|
  s.name = 'example'
  s.version = '1.0'
  s.summary = 'Example gem specification'
  ...
end</pre>

<p>For a great way to package gems, use Hoe.</p>

  
  
  


  
# Required gemspec attributes
  


  
    

## name

<p>This gem’s name</p>    

## require_paths

<p>Paths in the gem to add to $LOAD_PATH when this gem is activated.</p>

<p>The default [‘lib’] is typically sufficient.</p>    

## rubygems_version

<p>The version of RubyGems used to create this gem.</p>

<p>Do not set this, it is set automatically when the gem is packaged.</p>    

## specification_version

<p>The <a href="Specification.html">Gem::Specification</a> version of this
gemspec.</p>

<p>Do not set this, it is set automatically when the gem is packaged.</p>    

## summary

<p>A short summary of this gem’s description.  Displayed in `gem list -d`.</p>

<p>The description should be more detailed than the summary.  For example, you
might wish to copy the entire README into the description.</p>    

## version

<p>This gem’s version</p>    
  

  
# Optional gemspec attributes
  


  
    

## activated

<p>True when this gemspec has been activated. This attribute is not persisted.</p>    

## activated?

<p>True when this gemspec has been activated. This attribute is not persisted.</p>    

## autorequire

<p>Autorequire was used by old RubyGems to automatically require a file.</p>

<p>Deprecated: It is neither supported nor functional.</p>    

## bindir

<p>The path in the gem for executable scripts.  Usually ‘bin’</p>    

## cert_chain

<p>The certificate chain used to sign this gem.  See Gem::Security for
details.</p>    

## default_executable

<p>Sets the default executable for this gem.</p>

<p>Deprecated: You must now specify the executable name to  Gem.bin_path.</p>    

## description

<p>A long description of this gem</p>    

## email

<p>A contact email for this gem</p>

<p>If you are providing multiple authors and multiple emails they should be in
the same order such that:</p>

<pre>Hash[*spec.authors.zip(spec.emails).flatten]</pre>

<p>Gives a hash of author name to email address.</p>    

## homepage

<p>The URL of this gem’s home page</p>    

## loaded

<p>True when this gemspec has been activated. This attribute is not persisted.</p>    

## loaded?

<p>True when this gemspec has been activated. This attribute is not persisted.</p>    

## loaded_from

<p>Path this gemspec was loaded from.  This attribute is not persisted.</p>    

## post_install_message

<p>A message that gets displayed after the gem is installed</p>    

## required_ruby_version

<p>The version of ruby required by this gem</p>    

## required_rubygems_version

<p>The RubyGems version required by this gem</p>    

## rubyforge_project

<p>The rubyforge project this gem lives under.  i.e. RubyGems’ <a
href="Specification.html#attribute-i-rubyforge_project">rubyforge_project</a>
is “rubygems”.</p>    

## signing_key

<p>The key used to sign this gem.  See Gem::Security for details.</p>    
  

  


  
