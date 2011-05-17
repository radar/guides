---
layout: default
title: Command Reference
previous: /patterns
next: /specification-reference
---

What each `gem` command does, and how to use it.


* [gem build](#build)

* [gem cert](#cert)

* [gem check](#check)

* [gem cleanup](#cleanup)

* [gem contents](#contents)

* [gem dependency](#dependency)

* [gem environment](#environment)

* [gem fetch](#fetch)

* [gem generate_index](#generate_index)

* [gem help](#help)

* [gem install](#install)

* [gem list](#list)

* [gem lock](#lock)

* [gem outdated](#outdated)

* [gem owner](#owner)

* [gem pristine](#pristine)

* [gem push](#push)

* [gem query](#query)

* [gem rdoc](#rdoc)

* [gem search](#search)

* [gem server](#server)

* [gem sources](#sources)

* [gem specification](#specification)

* [gem stale](#stale)

* [gem uninstall](#uninstall)

* [gem unpack](#unpack)

* [gem update](#update)

* [gem which](#which)



## build

Build a gem from a gemspec

  
### Arguments

GEMSPEC_FILE  gemspec file name to build a gem for
  

### Usage

    gem build GEMSPEC_FILE

## cert

Manage RubyGems certificates and signing settings

  

### Usage

    gem cert

## check

Check installed gems

  

### Usage

    gem check

## cleanup

Clean up old versions of installed gems in the local repository

  
### Arguments

GEMNAME       name of gem to cleanup
  

### Usage

    gem cleanup [GEMNAME ...]

## contents

Display the contents of the installed gems

  
### Arguments

GEMNAME       name of gem to list contents for
  

### Usage

    gem contents GEMNAME [GEMNAME ...]

## dependency

Show the dependencies of an installed gem

  
### Arguments

GEMNAME       name of gem to show dependencies for
  

### Usage

    gem dependency GEMNAME

## environment

Display information about the RubyGems environment

  
### Arguments

packageversion  display the package version
gemdir          display the path where gems are installed
gempath         display path used to search for gems
version         display the gem format version
remotesources   display the remote gem servers
platform        display the supported gem platforms
&lt;omitted&gt;       display everything

  

### Usage

    gem environment [arg]

## fetch

Download a gem and place it in the current directory

  
### Arguments

GEMNAME       name of gem to download
  

### Usage

    gem fetch GEMNAME [GEMNAME ...]

## generate_index

Generates the index files for a gem server directory

  

### Usage

    gem generate_index

## help

Provide help on the 'gem' command

  
### Arguments

commands      List all 'gem' commands
examples      Show examples of 'gem' usage
&lt;command&gt;     Show specific help for &lt;command&gt;

  

### Usage

    gem help ARGUMENT

## install

Install a gem into the local repository

  
### Arguments

GEMNAME       name of gem to install
  

### Usage

    gem install GEMNAME [GEMNAME ...] [options] -- --build-flags

## list

Display gems whose name starts with STRING

  
### Arguments

STRING        start of gem name to look for
  

### Usage

    gem list [STRING]

## lock

Generate a lockdown list of gems

  
### Arguments

GEMNAME       name of gem to lock
VERSION       version of gem to lock
  

### Usage

    gem lock GEMNAME-VERSION [GEMNAME-VERSION ...]

## outdated

Display all gems that need updates

  

### Usage

    gem outdated

## owner

Manage gem owners on RubyGems.org.

  
### Arguments

GEM       gem to manage owners for
  

### Usage

    gem owner

## pristine

Restores installed gems to pristine condition from files located in the gem cache

  
### Arguments

GEMNAME       gem to restore to pristine condition (unless --all)
  

### Usage

    gem pristine [args]

## push

Push a gem up to RubyGems.org

  
### Arguments

GEM       built gem to push up
  

### Usage

    gem push GEM

## query

Query gem information in local or remote repositories

  

### Usage

    gem query

## rdoc

Generates RDoc for pre-installed gems

  
### Arguments

GEMNAME       gem to generate documentation for (unless --all)
  

### Usage

    gem rdoc [args]

## search

Display all gems whose name contains STRING

  
### Arguments

STRING        fragment of gem name to search for
  

### Usage

    gem search [STRING]

## server

Documentation and gem repository HTTP server

  

### Usage

    gem server

## sources

Manage the sources and cache file RubyGems uses to search for gems

  

### Usage

    gem sources

## specification

Display gem specification (in yaml)

  
### Arguments

GEMFILE       name of gem to show the gemspec for
FIELD         name of gemspec field to show

  

### Usage

    gem specification [GEMFILE] [FIELD]

## stale

List gems along with access times

  

### Usage

    gem stale

## uninstall

Uninstall gems from the local repository

  
### Arguments

GEMNAME       name of gem to uninstall
  

### Usage

    gem uninstall GEMNAME [GEMNAME ...]

## unpack

Unpack an installed gem to the current directory

  
### Arguments

GEMNAME       name of gem to unpack
  

### Usage

    gem unpack GEMNAME

## update

Update the named gems (or all installed gems) in the local repository

  
### Arguments

GEMNAME       name of gem to update
  

### Usage

    gem update GEMNAME [GEMNAME ...]

## which

Find the location of a library file you can require

  
### Arguments

FILE          name of file to find
  

### Usage

    gem which FILE [FILE ...]

