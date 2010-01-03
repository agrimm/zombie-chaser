$:.unshift File.join(File.dirname(__FILE__), *%w[.. ui])

require "test_unit_handler"
require "ui" #For actor superclass

class Human < Actor
  private_class_method :new
  attr_reader :successful_step_count

  def self.new_using_test_unit_handler(test_pattern, world)
    test_handler = TestUnitHandler.new(test_pattern)
    human = new(test_handler, world)
    human
  end

  def initialize(test_handler, world)
    @status = nil #Currently only used by zombie
    @world = world
    @successful_step_count = 0
    @health = :alive
    @test_handler = test_handler
  end

  def run
    test_running_thread = Thread.new do
      run_tests
    end
    status_updating_thread = Thread.new do
      update_view
    end
    status_updating_thread.join
    test_running_thread.join
  end

  def run_tests
    @test_handler.run
  end

  def update_view
    notify_world
    result_queue = @test_handler.result_queue
    while true
      #Assumption: result_queue will end with :end_of_work
      result = result_queue.deq
      case result
      when :pass
        notify_passing_step
      when :failure
        notify_failing_step
      when :end_of_work
        break
      else raise "Unknown result"
      end
    end
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

  def actor_state
    return "attacking" if @status == :attacking
    case @health
    when :alive
      "moving"
    when :dying
      "dying"
    when :dead
      "dead"
    end
  end

  def actor_direction
    270.0
  end

  def notify_passing_step
    @successful_step_count += 1
    sleep 0.1 #Hack to avoid it being too quick
    notify_world
  end

  def notify_failing_step
    @health = :dying
    sleep 0.5
    notify_world
  end

  def dying?
    @health == :dying
  end

  def dead?
    @health == :dead
  end

  def finish_dying
    sleep 0.5
    raise "I'm not dead yet!" unless dying?
    @health = :dead
    notify_world
    sleep 0.5
  end

  def notify_world
    @world.something_happened
  end

  def get_eaten
    @health = :dying unless dead?
  end

  def test_suite_size
    #This is valid from when @test_handler is initialized
    #And that is done when human is initialized
    @test_handler.test_suite_size
  end

end

class MockHuman < Human
  private_class_method :new

  def self.new_using_results(results, world)
    test_handler = MockTestHandler.new(results)
    mock_human = new(test_handler, world)
    mock_human
  end

  def sleep(duration)
    @world.sleep(duration)
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

  def all_zombies_run?
    @current_zombie_number == @zombies.length
  end
end

class ZombieList

  def self.new_using_test_unit_handler(test_pattern, world)
    new(test_pattern, world)
  end

  def initialize(test_pattern, world)
    @test_pattern, @world = test_pattern, world
  end

  def supply_next_zombie
    zombie = Zombie.new_using_test_unit_handler(@test_pattern, @world)
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

  def actor_direction
    90.0
  end

end

class Zombie < Human
  include ZombieInterface

  def eat(human)
    @status = :attacking #Even if the human's dead, look for leftovers
    human.get_eaten
  end
end

class MockZombie < MockHuman #Fixme provide a proper hierarchy
  include ZombieInterface

end
