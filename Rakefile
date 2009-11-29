task :default => [:test]

begin
  require 'jeweler'
  require File.dirname(__FILE__) + "/lib/chaser.rb"
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "chaser"
    gemspec.summary = "Unit test sadism, with less masochism"
    gemspec.description = "Lightweight mutation testing in any flavor of ruby"
    gemspec.email = "andrew.j.grimm@gmail.com"
    gemspec.authors = ["Andrew Grimm", "Ryan Davis", "Eric Hodel", "Kevin Clark"]
    #gemspec.add_dependency('test-unit') #FIXME Don't know how to only add the dependency for ruby 1.9
    gemspec.version = Chaser::VERSION
    gemspec.homepage = "http://andrewjgrimm.wordpress.com/2009/11/08/declare-war-on-everything-with-chaser/"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

task :test do
  ruby "test/test_unit.rb"
end

