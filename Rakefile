task :default => [:test]

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "zombie-chaser"
    gemspec.summary = "Lightweight mutation testing ... with ZOMBIES!!!"
    gemspec.description = "A zombie-themed graphic(al) user interface for mutation testing"
    gemspec.email = "andrew.j.grimm@gmail.com"
    gemspec.authors = ["Andrew Grimm", "Ryan Davis", "Eric Hodel", "Kevin Clark"]
    #gemspec.add_dependency('test-unit') #FIXME Don't know how to only add the dependency for ruby 1.9
    # Question about conditional dependency asked at http://stackoverflow.com/questions/1620342/how-do-i-add-conditional-rubygem-requirements-to-a-gem-specification
    #gemspec.add_dependency('gosu') #TODO ask rubygems people to make it possible to specify an optional runtime dependency
    # Comment about optional runtime dependencies at https://oree.ch/2009/06/06/rubygems-dependencies.html argues you shouldn't list optional dependencies
    #gemspec.version = ZombieTestChaser::VERSION #Can't access ZombieTestChaser without starting up test/unit
    gemspec.version = '0.0.3' # Check that it's consistent with ZombieTestChaser::VERSION
    gemspec.homepage = "http://andrewjgrimm.wordpress.com/2009/11/08/declare-war-on-everything-with-chaser/"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

#Fixme work out how to change this to TestTask without problems
task :test do
  ruby "-Ilib", "-Itest", "test/test_unit.rb"
end
