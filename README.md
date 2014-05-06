YARD-RSpec: A YARD extension for RSpec
=======================================

**Updated: May 07, 2014**

YARD-Rspec is a YARD plugin that processes specs files and includes them in the documentation.

This release takes the work started by
[@lsegal](https://github.com/lsegal/yard-spec-plugin),
[@kputnam](https://github.com/kputnam/yard-spec-plugin) and
[@Sage](https://github.com/Sage/yard-spec-plugin) and expands it to provide
better support for block type specs, and an updated README.

Installation
------------

To install this release add this line to your application's Gemfile:

    gem 'yard-spec-plugin', github: "nikhgupta/yard-spec-plugin"

Execute:

    $ bundle

Then edit the file _.yardopts_ with

    "{lib,app}/**/*.rb" "spec/{models,controllers,routing,mailers,lib,observers}/**/*.rb"  --plugin rspec


Usage
-----

Now you can execure yard doc with

    bundle exec yard doc
