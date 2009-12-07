task :default => [:test]

begin
  require 'jeweler'
  require File.dirname(__FILE__) + "/lib/zombie_test_chaser.rb"
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "zombie-chaser"
    gemspec.summary = "Lightweight mutation testing ... with ZOMBIES!!!"
    gemspec.description = "A zombie-themed graphic(al) user interface for mutation testing"
    gemspec.email = "andrew.j.grimm@gmail.com"
    gemspec.authors = ["Andrew Grimm", "Ryan Davis", "Eric Hodel", "Kevin Clark"]
    #gemspec.add_dependency('test-unit') #FIXME Don't know how to only add the dependency for ruby 1.9
    gemspec.add_dependency('gosu') #FIXME add option for command-line version, which'll make gosu an optional dependency
    gemspec.version = ZombieTestChaser::VERSION
    gemspec.homepage = "http://andrewjgrimm.wordpress.com/2009/11/08/declare-war-on-everything-with-chaser/"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

task :test do
  ruby "test/test_unit.rb"
end

