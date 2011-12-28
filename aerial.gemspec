# aerial.gemspec
# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "aerial/version"

Gem::Specification.new do |s|
  s.name        = "aerial"
  s.version     = Aerial::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Sears"]
  s.email       = ["matt@mattsears.com"]
  s.homepage    = "http://mattsears.com"
  s.summary     = %q{Aerial}
  s.description = %q{A simple, blogish software build with Sinatra, jQuery, and uses Git for data storage}
  s.add_development_dependency "rspec"
  # s.add_dependency 'grit', '> 0.1', '<= 0.5'
  s.add_dependency 'grit'
  s.add_dependency 'thor'
  s.add_dependency 'thin'
  s.add_dependency 'sinatra'
  s.add_dependency 'haml'
  s.add_dependency 'redcarpet', '1.17.2'
  s.add_dependency 'albino'
  s.add_dependency 'nokogiri'
  s.add_dependency 'html_truncator'

  s.rubyforge_project = "aerial"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
