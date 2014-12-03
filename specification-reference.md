---
layout: default
title: Specification Reference
url: /specification-refence
previous: /patterns
next: /command-reference
---



<p>The Specification class contains the
information for a Gem.  Typically defined in a .gemspec file or a Rakefile,
and looks like this:</p>

<pre class="ruby"><span class="ruby-constant">Gem</span><span class="ruby-operator">::</span><span class="ruby-constant">Specification</span>.<span class="ruby-identifier">new</span> <span class="ruby-keyword">do</span> <span class="ruby-operator">|</span><span class="ruby-identifier">s</span><span class="ruby-operator">|</span>
  <span class="ruby-identifier">s</span>.<span class="ruby-identifier">name</span>        = <span class="ruby-string">&#39;example&#39;</span>
  <span class="ruby-identifier">s</span>.<span class="ruby-identifier">version</span>     = <span class="ruby-string">&#39;0.1.0&#39;</span>
  <span class="ruby-identifier">s</span>.<span class="ruby-identifier">licenses</span>    = [<span class="ruby-string">&#39;MIT&#39;</span>]
  <span class="ruby-identifier">s</span>.<span class="ruby-identifier">summary</span>     = <span class="ruby-string">&quot;This is an example!&quot;</span>
  <span class="ruby-identifier">s</span>.<span class="ruby-identifier">description</span> = <span class="ruby-string">&quot;Much longer explanation of the example!&quot;</span>
  <span class="ruby-identifier">s</span>.<span class="ruby-identifier">authors</span>     = [<span class="ruby-string">&quot;Ruby Coder&quot;</span>]
  <span class="ruby-identifier">s</span>.<span class="ruby-identifier">email</span>       = <span class="ruby-string">&#39;rubycoder@example.com&#39;</span>
  <span class="ruby-identifier">s</span>.<span class="ruby-identifier">files</span>       = [<span class="ruby-string">&quot;lib/example.rb&quot;</span>]
  <span class="ruby-identifier">s</span>.<span class="ruby-identifier">homepage</span>    = <span class="ruby-string">&#39;https://rubygems.org/gems/example&#39;</span>
<span class="ruby-keyword">end</span>
</pre>

<p>Starting in RubyGems 2.0, a Specification
can hold arbitrary metadata.  See metadata for
restrictions on the format and size of metadata items you may add to a
specification.</p>



## Required gemspec attributes
    
* [author=](#author=)
    
* [authors=](#authors=)
    
* [files](#files)
    
* [name](#name)
    
* [platform=](#platform=)
    
* [require_paths=](#require_paths=)
    
* [rubygems_version](#rubygems_version)
    
* [summary](#summary)
    
* [version](#version)
    
## Recommended gemspec attributes
    
* [license=](#license=)
    
* [licenses=](#licenses=)
    
## Optional gemspec attributes
    
* [add_development_dependency](#add_development_dependency)
    
* [add_runtime_dependency](#add_runtime_dependency)
    
* [bindir](#bindir)
    
* [cert_chain](#cert_chain)
    
* [description](#description)
    
* [email](#email)
    
* [executables](#executables)
    
* [extensions](#extensions)
    
* [extra_rdoc_files](#extra_rdoc_files)
    
* [homepage](#homepage)
    
* [metadata](#metadata)
    
* [post_install_message](#post_install_message)
    
* [rdoc_options](#rdoc_options)
    
* [required_ruby_version](#required_ruby_version)
    
* [required_ruby_version=](#required_ruby_version=)
    
* [required_rubygems_version](#required_rubygems_version)
    
* [required_rubygems_version=](#required_rubygems_version=)
    
* [requirements](#requirements)
    
* [signing_key](#signing_key)
    


# Required gemspec attributes



<a id="author="> </a>

## author=(`o`)

<p>Singular writer for authors</p>

<p>Usage:</p>

<pre>spec.author = &#39;John Jones&#39;</pre>    

<a id="authors="> </a>

## authors=(`value`)

<p>Sets the list of authors, ensuring it is an array.</p>

<p>Usage:</p>

<pre>spec.authors = [&#39;John Jones&#39;, &#39;Mary Smith&#39;]</pre>    

<a id="files"> </a>

## files

<p>Files included in this gem.  You cannot append to this accessor, you must
assign to it.</p>

<p>Only add files you can require to this list, not directories, etc.</p>

<p>Directories are automatically stripped from this list when building a gem,
other non-files cause an error.</p>

<p>Usage:</p>

<pre class="ruby"><span class="ruby-identifier">require</span> <span class="ruby-string">&#39;rake&#39;</span>
<span class="ruby-identifier">spec</span>.<span class="ruby-identifier">files</span> = <span class="ruby-constant">FileList</span>[<span class="ruby-string">&#39;lib     .rb&#39;</span>,
                      <span class="ruby-string">&#39;bin/*&#39;</span>,
                      <span class="ruby-string">&#39;[A-Z]*&#39;</span>,
                      <span class="ruby-string">&#39;test/   *&#39;</span>].<span class="ruby-identifier">to_a</span>

<span class="ruby-comment"># or without Rake...</span>
<span class="ruby-identifier">spec</span>.<span class="ruby-identifier">files</span> = <span class="ruby-constant">Dir</span>[<span class="ruby-string">&#39;lib/   *.rb&#39;</span>] <span class="ruby-operator">+</span> <span class="ruby-constant">Dir</span>[<span class="ruby-string">&#39;bin/*&#39;</span>]
<span class="ruby-identifier">spec</span>.<span class="ruby-identifier">files</span> <span class="ruby-operator">+=</span> <span class="ruby-constant">Dir</span>[<span class="ruby-string">&#39;[A-Z]*&#39;</span>] <span class="ruby-operator">+</span> <span class="ruby-constant">Dir</span>[<span class="ruby-string">&#39;test/**/*&#39;</span>]
<span class="ruby-identifier">spec</span>.<span class="ruby-identifier">files</span>.<span class="ruby-identifier">reject!</span> { <span class="ruby-operator">|</span><span class="ruby-identifier">fn</span><span class="ruby-operator">|</span> <span class="ruby-identifier">fn</span>.<span class="ruby-identifier">include?</span> <span class="ruby-string">&quot;CVS&quot;</span> }
</pre>    

<a id="name"> </a>

## name

<p>This gem&#39;s name.</p>

<p>Usage:</p>

<pre>spec.name = &#39;rake&#39;</pre>    

<a id="platform="> </a>

## platform=(`platform`)

<p>The platform this gem runs on.</p>

<p>This is usually Gem::Platform::RUBY or Gem::Platform::CURRENT.</p>

<p>Most gems contain pure Ruby code; they should simply leave the default
value in place.  Some gems contain C (or other) code to be compiled into a
Ruby “extension”.  The gem should leave the default value in place unless
the code will only compile on a certain type of system.  Some gems consist
of pre-compiled code (“binary gems”).  It&#39;s especially important that
they set the platform attribute appropriately.  A shortcut is to set the
platform to Gem::Platform::CURRENT, which will cause the gem builder to set
the platform to the appropriate value for the system on which the build is
being performed.</p>

<p>If this attribute is set to a non-default value, it will be included in the
filename of the gem when it is built such as:
nokogiri-1.6.0-x86-mingw32.gem</p>

<p>Usage:</p>

<pre>spec.platform = Gem::Platform.local</pre>    

<a id="require_paths="> </a>

## require_paths=(`val`)

<p>Paths in the gem to add to <code>$LOAD_PATH</code> when this gem is
activated.</p>

<p>See also require_paths</p>

<p>If you have an extension you do not need to add
<code>&quot;ext&quot;</code> to the require path, the extension build
process will copy the extension files into “lib” for you.</p>

<p>The default value is <code>&quot;lib&quot;</code></p>

<p>Usage:</p>

<pre># If all library files are in the root directory...
spec.require_paths = [&#39;.&#39;]</pre>    

<a id="rubygems_version"> </a>

## rubygems_version

<p>The version of RubyGems used to create this gem.</p>

<p>Do not set this, it is set automatically when the gem is packaged.</p>    

<a id="summary"> </a>

## summary

<p>A short summary of this gem&#39;s description.  Displayed in `gem list -d`.</p>

<p>The description
should be more detailed than the summary.</p>

<p>Usage:</p>

<pre>spec.summary = &quot;This is a small summary of my gem&quot;</pre>    

<a id="version"> </a>

## version

<p>This gem&#39;s version.</p>

<p>The version string can contain numbers and periods, such as
<code>1.0.0</code>. A gem is a &#39;prerelease&#39; gem if the version has
a letter in it, such as <code>1.0.0.pre</code>.</p>

<p>Usage:</p>

<pre>spec.version = &#39;0.4.1&#39;</pre>    

# Recommended gemspec attributes



<a id="license="> </a>

## license=(`o`)

<p>The license for this gem.</p>

<p>The license must be no more than 64 characters.</p>

<p>This should just be the name of your license. The full text of the license
should be inside of the gem (at the top level) when you build it.</p>

<p>The simplest way, is to specify the standard SPDX ID <a
href="https://spdx.org/licenses">spdx.org/licenses</a>/ for the license.
Ideally you should pick one that is OSI (Open Source Initiative) <a
href="http://opensource.org/licenses/alphabetical">opensource.org/licenses/alphabetical</a>
approved.</p>

<p>The most commonly used OSI approved licenses are BSD-3-Clause and MIT.
GitHub also provides a license picker at <a
href="http://choosealicense.com">choosealicense.com</a>/.</p>

<p>You should specify a license for your gem so that people know how they are
permitted to use it, and any restrictions you&#39;re placing on it.  Not
specifying a license means all rights are reserved; others have no rights
to use the code for any purpose.</p>

<p>You can set multiple licenses with licenses=</p>

<p>Usage:</p>

<pre>spec.license = &#39;MIT&#39;</pre>    

<a id="licenses="> </a>

## licenses=(`licenses`)

<p>The license(s) for the library.</p>

<p>Each license must be a short name, no more than 64 characters.</p>

<p>This should just be the name of your license. The full text of the license
should be inside of the gem when you build it.</p>

<p>See license= for more
discussion</p>

<p>Usage:</p>

<pre>spec.licenses = [&#39;MIT&#39;, &#39;GPL-2&#39;]</pre>    

# Optional gemspec attributes



<a id="add_development_dependency"> </a>

## add_development_dependency(`gem`, `*requirements`)

<p>Adds a development dependency named <code>gem</code> with
<code>requirements</code> to this gem.</p>

<p>Usage:</p>

<pre>spec.add_development_dependency &#39;example&#39;, &#39;~&gt; 1.1&#39;, &#39;&gt;= 1.1.4&#39;</pre>

<p>Development dependencies aren&#39;t installed by default and aren&#39;t
activated when a gem is required.</p>    

<a id="add_runtime_dependency"> </a>

## add_runtime_dependency(`gem`, `*requirements`)

<p>Adds a runtime dependency named <code>gem</code> with
<code>requirements</code> to this gem.</p>

<p>Usage:</p>

<pre>spec.add_runtime_dependency &#39;example&#39;, &#39;~&gt; 1.1&#39;, &#39;&gt;= 1.1.4&#39;</pre>    

<a id="bindir"> </a>

## bindir

<p>The path in the gem for executable scripts.  Usually &#39;bin&#39;</p>

<p>Usage:</p>

<pre>spec.bindir = &#39;bin&#39;</pre>    

<a id="cert_chain"> </a>

## cert_chain

<p>The certificate chain used to sign this gem.  See Gem::Security for
details.</p>    

<a id="description"> </a>

## description

<p>A long description of this gem</p>

<p>The description should be more detailed than the summary but not
excessively long.  A few paragraphs is a recommended length with no
examples or formatting.</p>

<p>Usage:</p>

<pre>spec.description = &lt;&lt;-EOF
  Rake is a Make-like program implemented in Ruby. Tasks and
  dependencies are specified in standard Ruby syntax.
EOF</pre>    

<a id="email"> </a>

## email

<p>A contact email address (or addresses) for this gem</p>

<p>Usage:</p>

<pre>spec.email = &#39;john.jones@example.com&#39;
spec.email = [&#39;jack@example.com&#39;, &#39;jill@example.com&#39;]</pre>    

<a id="executables"> </a>

## executables

<p>Executables included in the gem.</p>

<p>For example, the rake gem has rake as an executable. You don’t specify the
full path (as in bin/rake); all application-style files are expected to be
found in bindir.  These files must be executable Ruby files.  Files that
use bash or other interpreters will not work.</p>

<p>Executables included may only be ruby scripts, not scripts for other
languages or compiled binaries.</p>

<p>Usage:</p>

<pre>spec.executables &lt;&lt; &#39;rake&#39;</pre>    

<a id="extensions"> </a>

## extensions

<p>Extensions to build when installing the gem, specifically the paths to
extconf.rb-style files used to compile extensions.</p>

<p>These files will be run when the gem is installed, causing the C (or
whatever) code to be compiled on the user’s machine.</p>

<p>Usage:</p>

<pre>spec.extensions &lt;&lt; &#39;ext/rmagic/extconf.rb&#39;</pre>

<p>See Gem::Ext::Builder for information about writing extensions for gems.</p>    

<a id="extra_rdoc_files"> </a>

## extra_rdoc_files

<p>Extra files to add to RDoc such as README or doc/examples.txt</p>

<p>When the user elects to generate the RDoc documentation for a gem
(typically at install time), all the library files are sent to RDoc for
processing. This option allows you to have some non-code files included for
a more complete set of documentation.</p>

<p>Usage:</p>

<pre>spec.extra_rdoc_files = [&#39;README&#39;, &#39;doc/user-guide.txt&#39;]</pre>    

<a id="homepage"> </a>

## homepage

<p>The URL of this gem&#39;s home page</p>

<p>Usage:</p>

<pre>spec.homepage = &#39;http://rake.rubyforge.org&#39;</pre>    

<a id="metadata"> </a>

## metadata

<p>:attr_accessor: metadata</p>

<p>The metadata holds extra data for this gem that may be useful to other
consumers and is settable by gem authors without requiring an update to the
rubygems software.</p>

<p>Metadata items have the following restrictions:</p>
<ul><li>
<p>The metadata must be a Hash object</p>
</li><li>
<p>All keys and values must be Strings</p>
</li><li>
<p>Keys can be a maximum of 128 bytes and values can be a maximum of 1024
bytes</p>
</li><li>
<p>All strings must be UTF-8, no binary data is allowed</p>
</li></ul>

<p>To add metadata for the location of a issue tracker:</p>

<pre class="ruby"><span class="ruby-identifier">s</span>.<span class="ruby-identifier">metadata</span> = { <span class="ruby-string">&quot;issue_tracker&quot;</span> =<span class="ruby-operator">&gt;</span> <span class="ruby-string">&quot;https://example/issues&quot;</span> }
</pre>    

<a id="post_install_message"> </a>

## post_install_message

<p>A message that gets displayed after the gem is installed.</p>

<p>Usage:</p>

<pre>spec.post_install_message = &quot;Thanks for installing!&quot;</pre>    

<a id="rdoc_options"> </a>

## rdoc_options

<p>Specifies the rdoc options to be used when generating API documentation.</p>

<p>Usage:</p>

<pre>spec.rdoc_options &lt;&lt; &#39;--title&#39; &lt;&lt; &#39;Rake -- Ruby Make&#39; &lt;&lt;
  &#39;--main&#39; &lt;&lt; &#39;README&#39; &lt;&lt;
  &#39;--line-numbers&#39;</pre>    

<a id="required_ruby_version"> </a>

## required_ruby_version

<p>The version of Ruby required by this gem</p>    

<a id="required_ruby_version="> </a>

## required_ruby_version=(`req`)

<p>The version of Ruby required by this gem.  The ruby version can be
specified to the patch-level:</p>

<pre>$ ruby -v -e &#39;p Gem.ruby_version&#39;
ruby 2.0.0p247 (2013-06-27 revision 41674) [x86_64-darwin12.4.0]
#&lt;Gem::Version &quot;2.0.0.247&quot;&gt;</pre>

<p>Usage:</p>

<pre># This gem will work with 1.8.6 or greater...
spec.required_ruby_version = &#39;&gt;= 1.8.6&#39;

# Only with ruby 2.0.x
spec.required_ruby_version = &#39;~&gt; 2.0&#39;</pre>    

<a id="required_rubygems_version"> </a>

## required_rubygems_version

<p>The RubyGems version required by this gem</p>    

<a id="required_rubygems_version="> </a>

## required_rubygems_version=(`req`)

<p>The RubyGems version required by this gem</p>    

<a id="requirements"> </a>

## requirements

<p>Lists the external (to RubyGems) requirements that must be met for this gem
to work.  It&#39;s simply information for the user.</p>

<p>Usage:</p>

<pre>spec.requirements &lt;&lt; &#39;libmagick, v6.0&#39;
spec.requirements &lt;&lt; &#39;A good graphics card&#39;</pre>    

<a id="signing_key"> </a>

## signing_key

<p>The key used to sign this gem.  See Gem::Security for details.</p>    


<!--<html -->
