require 'rubygems'
require 'spec/version'
require 'spec/rake/spectask'
require 'cucumber/rake/task'

AERIAL_ROOT = "."
require File.join(AERIAL_ROOT, 'lib', 'aerial')
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

desc "Setup the directory structure"
task :bootstrap do
  Rake::Task['setup:articles_directory'].invoke
  Rake::Task['setup:views_directory'].invoke
  Rake::Task['setup:public_directory'].invoke
  Rake::Task['run'].invoke
end

desc 'Run Aerial in development mode'
task :run do
  exec "ruby lib/aerial.rb"
end

desc "Launch Aerial cartwheel"
task :launch do
  ruby "bin/aerial launch"
end

namespace :setup do

  desc "Copy over a sample article"
  task :articles_directory do
    puts "* Creating article directory in " + Aerial.config.views.dir
    article_dir = File.join(AERIAL_ROOT, 'lib','spec','fixtures',
                            'articles', 'congratulations-aerial-is-configured-correctly')
    FileUtils.mkdir_p(Aerial.config.articles.dir )
    FileUtils.cp_r(article_dir, Aerial.config.articles.dir )
    Aerial::Git.commit(Aerial.config.articles.dir, "Initial import of first article")
  end

  task :public_directory do
    puts "* Creating public directory in " + Aerial.config.public.dir
    FileUtils.cp_r(File.join(AERIAL_ROOT, 'lib', 'spec',
                             'fixtures', 'public'),
                   Aerial.config.public.dir )
  end

  task :views_directory do
    puts "* Creating views directory in " + Aerial.config.views.dir
    FileUtils.cp_r(File.join(AERIAL_ROOT, 'lib', 'spec',
                             'fixtures',  'views'),
                   Aerial.config.views.dir )
  end
end

# Cucumber setup
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty"
end

# Vlad setup
begin
  require "vlad"
  Vlad.load(:app => nil, :scm => "git")
rescue LoadError
  # do nothing
end

desc "Build a gem"
task :gem => [ :gemspec, :build ]

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
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
