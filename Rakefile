require 'rubygems'
require 'spec/version'
require 'spec/rake/spectask'
require 'git'
require 'grit'
# TODO: refactor config file loading in base.rb
require 'lib/aerial/config'

# Rspec setup
desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run all specs with rcov"
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_dir = 'coverage'
    t.rcov_opts = ['--exclude',
                   "lib/spec.rb,spec\/spec,bin\/spec,examples,\.autotest,#{Gem.path.join(',')}"]
  end
end

desc "Launch Aerial cartwheel"
task :launch do
  ruby "bin/aerial launch"
end

# Vlad setup
begin
  require "vlad"
  Vlad.load(:app => nil, :scm => "git")
rescue LoadError
  # do nothing
end

desc "Build a gem"
task :gem => [ :gemspec, :build ] do
  command = "gem install --local ./pkg/aerial-0.1.0.gem"
  sh command
end

desc "Build a gem"
task :rdoc do
  sh 'mkdir rdoc'
  sh 'echo documentation is at http://github.com/mattsears/aerial > rdoc/README.rdoc'
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "aerial"
    gemspec.summary = "A simple, blogish software build with Sinatra, jQuery, and uses Git for data storage  "
    gemspec.description = "A simple, blogish software build with Sinatra, jQuery, and uses Git for data storage  "
    gemspec.email = "matt@mattsears.com"
    gemspec.homepage = "http://github.com/mattsears/aerial"
    gemspec.description = "A simple, blogish software build with Sinatra, jQuery, and uses Git for data storage"
    gemspec.authors = ["Matt Sears"]
    gemspec.rubyforge_project = 'aerial'
  end
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end


