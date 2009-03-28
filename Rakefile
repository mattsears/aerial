# $:.unshift(File.dirname(__FILE__) + '/../../../lib')

require 'rubygems'
require 'spec/version'
require 'spec/rake/spectask'
require 'cucumber/rake/task'

AERIAL_ROOT = "."
require File.join(AERIAL_ROOT, 'lib', 'aerial')

# Rspec setup
desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['lib/spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run all specs with rcov"
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = FileList['lib/spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_dir = 'coverage'
    t.rcov_opts = ['--exclude',
                   "lib/spec.rb,spec\/spec,bin\/spec,examples,\.autotest,#{ENV['GEM_HOME']}"]
  end
end

desc "Setup the directory structure"
task :boostrap do
  Rake::Task['setup:articles_directory'].invoke
  Rake::Task['setup:views_directory'].invoke
  Rake::Task['setup:public_directory'].invoke
end

desc 'Run Aerial in development mode'
task :run do
  exec "ruby lib/aerial.rb"
end

namespace :setup do

  desc "Copy over a sample article"
  task :articles_directory do
    puts "* Creating article directory in " + Aerial.config.views.dir
    FileUtils.mkdir_p( Aerial.config.articles.dir )
    FileUtils.cp_r(File.join(AERIAL_ROOT,
                               'lib',
                                 'spec',
                                   'fixtures',
                                     'articles',
                                       'test-article-one'),
                   Aerial.config.articles.dir )
  end

  task :public_directory do
    puts "* Creating public directory in " + Aerial.config.public.dir
    FileUtils.cp_r(File.join(AERIAL_ROOT,
                               'lib',
                                 'spec',
                                   'fixtures',
                                     'public'),
                   Aerial.config.public.dir )
  end

  task :views_directory do
    puts "* Creating views directory in " + Aerial.config.views.dir
    FileUtils.cp_r(File.join(AERIAL_ROOT,
                             'lib',
                               'spec',
                                 'fixtures',
                                   'views'),
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
