#!/usr/bin/env ruby

require "test/unit/collector/objectspace"
require "test/unit/ui/testrunnermediator"
require 'chaser'

$: << 'lib' << 'test'

# Make sure test/unit doesn't swallow our timeout
begin
  Test::Unit::TestCase::PASSTHROUGH_EXCEPTIONS << Chaser::Timeout
rescue NameError
  # ignore
end

class ZombieTestChaser < Chaser

  VERSION = '0.0.3' #This should be used, but isn't, in Rakefile.

  @@test_pattern = 'test/test_*.rb'
  @@tests_loaded = false
  @@world = nil

  def self.test_pattern=(value)
    @@test_pattern = value
  end

  def self.create_world
    @@tests_loaded = true
    @@world = World.new_using_test_unit_handler(@@test_pattern)
  end

  def self.world
    @@world
  end

  def self.current_class_names(exclude_list)
    result = []
    ObjectSpace.each_object(Class) do |klass|
      next if klass.to_s.include?("Class:0x")
      next unless klass.ancestors.all? {|ancestor| (ancestor.to_s.split(/::/) & exclude_list).empty?}
      result << klass.to_s
    end
    result
  end

  def self.validate(klass_name = nil, method_name = nil, force = false)
    pre_existing_class_names = self.current_class_names([]) unless klass_name
    create_world

    if klass_name
      klass = klass_name.to_class
      # Does the method exist?
      klass_methods = klass.singleton_methods(false).collect {|meth| "self.#{meth}"}
      if method_name
        if method_name =~ /self\./
          abort "Unknown method: #{klass_name}.#{method_name.gsub('self.', '')}" unless klass_methods.include? method_name
        else
          abort "Unknown method: #{klass_name}##{method_name}" unless klass.instance_methods(false).map{|sym| sym.to_s}.include? method_name
        end
      end
    end

    initial_time = Time.now

    chaser = self.new(klass_name)

    all_good = nil

    chaser.while_world_running do

      passed = chaser.human_survives?

      unless force or passed then
        abort "Initial run of tests failed... fix and run chaser again"
      end

      if self.guess_timeout? then
        running_time = Time.now - initial_time
        adjusted_timeout = (running_time * 2 < 5) ? 5 : (running_time * 2).ceil
        self.timeout = adjusted_timeout
      end

      puts "Timeout set to #{adjusted_timeout} seconds."

      if passed then
        puts "Initial tests pass. Let's rumble."
      else
        puts "Initial tests failed but you forced things. Let's rumble."
      end
      puts

      counts = Hash.new(0)

      klass_names = klass_name ? Array(klass_name) : self.current_class_names(["Test"]) - pre_existing_class_names
      klass_names.each do |block_klass_name|
        block_klass = block_klass_name.to_class

        methods = method_name ? Array(method_name) : block_klass.instance_methods(false) + block_klass.singleton_methods(false).collect {|meth| "self.#{meth}"}

        methods.sort.each do |block_method_name|
          result = self.new(block_klass_name, block_method_name).validate
          counts[result] += 1
        end
      end
      all_good = counts[false] == 0

      puts "Chaser Results:"
      puts
      puts "Passed    : %3d" % counts[true]
      puts "Failed    : %3d" % counts[false]
      puts

      if all_good then
        puts "All chasing was thwarted! YAY!!!"
      else
        puts "Improve the tests and try again."
      end

    end
    all_good
  end

  def human_survives?
    self.class.world.run_human
  end

  def zombie_survives?
    self.class.world.run_next_zombie
  end

  def while_world_running
    self.class.world.while_world_running{yield}
  end

  def initialize(klass_name=nil, method_name=nil)
    super
    self.class.create_world unless @@tests_loaded
  end

end
