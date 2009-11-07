task :default => [:test]

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "chaser"
    gemspec.summary = "Unit test sadism, with less masochism"
    gemspec.description = "Lightweight mutation testing in any flavor of ruby"
    gemspec.email = "andrew.j.grimm@gmail.com"
    gemspec.authors = ["Andrew Grimm", "Ryan Davis", "Eric Hodel", "Kevin Clark"]
    gemspec.add_dependency('test-unit') #Ruby 1.9 doesn't have full test-unit in the standard library.
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

task :test do
  ruby "test/test_chaser.rb"
end

