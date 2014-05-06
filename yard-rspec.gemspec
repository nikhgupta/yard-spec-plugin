# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name          = "yard-rspec"
  s.summary       = "YARD plugin to list RSpec specifications inside documentation" 
  s.version       = "0.2"
  s.date          = "2012-04-24"
  s.authors       = ["Loren Segal", "@pqmodn", "@ogeidix"]
  s.homepage      = "http://yardoc.org"
  s.platform      = Gem::Platform::RUBY
  s.files         = Dir.glob("{example,lib,templates}/**/*") + ['LICENSE', 'README.md', 'Rakefile']
  s.require_paths = ['lib']
  s.has_rdoc      = 'yard'
  s.rubyforge_project = 'yard-rspec'
  s.add_dependency 'yard' 
end
