$:.unshift File.join(File.dirname(__FILE__), *%w[.. ui])

require "test_unit_handler"
require "ui" #For actor superclass

class Human < Actor
  private_class_method :new
  attr_reader :successful_step_count

  def self.new_using_test_unit_handler(test_pattern, world)
    new(test_pattern, world)
  end

  def initialize(test_pattern, world)
    @world = world
    @successful_step_count = 0
    @health = :alive
    @test_handler = TestUnitHandler.new(test_pattern, self)
  end

  def run
    notify_world
    @test_handler.run
  end

  def current_symbol
    case @health
    when :alive
      "@"
    when :dying
      "*"
    when :dead
      "+"
    end
  end

  def actor_type
    'robot'
  end

  def notify_passing_step
    @successful_step_count += 1
    notify_world
  end

  def notify_failing_step
    @health = :dying
    notify_world
  end

  def dying?
    @health == :dying
  end

  def dead?
    @health == :dead
  end

  def finish_dying
    raise "I'm not dead yet!" unless dying?
    @health = :dead
    notify_world
  end

  def notify_world
    @world.something_happened
  end
end

class MockHuman < Human
  private_class_method :new

  def self.new_using_results(results, world)
    new(results, world)
  end

  def initialize(results, world)
    @world = world
    @results = results
    @successful_step_count = 0
    @health = :alive
  end

  def run
    until @successful_step_count == @results.size
      if @results[@successful_step_count] == :failure
        @health = :dying
        notify_world
        return
      end
      notify_world
      @successful_step_count += 1
    end
    notify_world
  end
end

class MockZombieList

  def self.new_using_results(zombies_results, world)
    zombies = zombies_results.map do |zombie_results|
      MockZombie.new_using_results(zombie_results, world)
    end
    new(zombies)
  end

  def initialize(zombies)
    @zombies = zombies
    @current_zombie_number = 0
  end

  def supply_next_zombie
    zombie = @zombies[@current_zombie_number]
    @current_zombie_number += 1
    zombie
  end

  def all_slain?
    @current_zombie_number == @zombies.length
  end
end

module ZombieInterface
  def current_symbol
    case @health
    when :alive
      "Z"
    when :dying
      "*"
    when :dead
      "+"
    end
  end

  def actor_type
    'zombie'
  end
end

class Zombie < Human
  include ZombieInterface
end

class MockZombie < MockHuman #Fixme provide a proper hierarchy
  include ZombieInterface

end
