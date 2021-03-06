require "zombie-chaser/test_unit_handler"
require "zombie-chaser/ui" #For actor superclass

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
    @view_queue = Queue.new
    @angle = Math::PI * rand * 2.0
  end

  def run
    test_running_thread = Thread.new do
      run_tests
    end
    view_queue_updating_thread = Thread.new do
      build_view_queue
    end
    status_updating_thread = Thread.new do
      update_view
    end
    status_updating_thread.join
    view_queue_updating_thread.join
    test_running_thread.join
  end

  def run_tests
    @test_handler.run
  end

  def build_view_queue
    while true
      result = @test_handler.result_queue.deq #Slight law of demeter violation
      case result
      when :pass
        @view_queue.enq(:passing_step)
      when :failure
        @view_queue.enq(:start_dying)
        @view_queue.enq(:finish_dying)
      when :end_of_work
        @view_queue.enq(:end_of_work)
        break
      else raise "Unknown result!"
      end
    end
    @view_queue.enq(:end_of_work)
  end

  def update_view
    notify_world
    while true
      result = @view_queue.deq
      case result
      when :passing_step
        notify_passing_step
      when :start_dying
        notify_start_dying
      when :finish_dying
        notify_finish_dying
      when :end_of_work
        notify_finished
        break
      else raise "Unknown result!"
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
    @angle * -360.0 / (2 * Math::PI)
  end

  def notify_passing_step
    break_out_of_loop = false
    while true
      # This synchronization doesn't actually work. The unit test dont_test_zombies_do_not_collide seem to pass on 1.8 and fail on 1.9, though it could be coincidence.
      # Fixme Find out why my use of synchronization doesn't work, while remembering that select is not broken.
      @world.synchronize_for_collision_detection do
        if no_other_living_zombies_in?(@successful_step_count + 1)
          @successful_step_count += 1
          break_out_of_loop = true
        end
      end
      break if break_out_of_loop
      shuffle_in_one_place
    end
    increase_angle_by(13) if defined?(@lurch_offset)
    sleep([0.1, 2.0 / test_suite_size].min)
    notify_world
  end

  def no_other_living_zombies_in?(desired_step_count)
    @world.no_living_zombies_apart_from_me?(desired_step_count, self)
  end

  def notify_start_dying
    @health = :dying
    sleep 0.5
    notify_world
  end

  def dying?
    @health == :dying
  end
  private :dying?

  def dead?
    @health == :dead
  end

  def notify_finish_dying
    sleep 0.5
    raise "I'm not dead yet!" unless dying?
    @health = :dead
    notify_world
    sleep 0.5
  end

  def notify_finished
    #Do nothing in humans
  end

  def notify_world
    @world.something_happened
  end

  def get_eaten
    @health = :dead unless dead?
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

class ZombieFactory
  def initialize(test_pattern, world)
    @test_pattern, @world = test_pattern, world
  end

  def create_zombie
    Zombie.new_using_test_unit_handler(@test_pattern, @world)
  end
end

class ZombieList

  def self.new_using_test_unit_handler(test_pattern, world)
    zombie_factory = ZombieFactory.new(test_pattern, world)
    new(zombie_factory)
  end

  def initialize(zombie_factory)
    @zombie_factory = zombie_factory
    @zombies = []
  end

  def supply_next_zombie
    zombie = @zombie_factory.create_zombie
    @zombies << zombie
    zombie
  end

  def each_zombie
    @zombies.each{|zombie| yield zombie}
  end

  def draw_zombies
    each_zombie {|zombie| zombie.draw}
  end
end

class MockZombieFactory
  def initialize(zombies_results, world)
    @zombies_results, @world = zombies_results, world
    @current_zombie_number = 0
  end

  def create_zombie
    mock_zombie = MockZombie.new_using_results(@zombies_results[@current_zombie_number], @world)
    @current_zombie_number += 1
    mock_zombie
  end
end

class MockZombieList < ZombieList

  def self.new_using_results(zombies_results, world)
    mock_zombie_factory = MockZombieFactory.new(zombies_results, world)
    new(mock_zombie_factory)
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

  def shuffle_in_one_place
    shuffle_amount = 17
    increase_angle_by(shuffle_amount)
    sleep 0.1
  end

  def increase_angle_by(amount)
    minimum_lurch_offset = -20
    maximum_lurch_offset = 20
    @lurch_offset = (@lurch_offset + amount - minimum_lurch_offset) % (maximum_lurch_offset - minimum_lurch_offset) + minimum_lurch_offset
  end

  def notify_finished
    eat_human unless dead?
  end

  def eat_human
    @status = :attacking #Even if the human's dead, look for leftovers
    @world.notify_human_eaten
    sleep 1
    @status = nil
  end

end

class Zombie < Human
  include ZombieInterface

  def initialize(*args)
    @lurch_offset = 0
    super
  end

  def actor_direction
    (@angle * -360.0 / (2 * Math::PI) + @lurch_offset)
  end
end

class MockZombie < MockHuman #Fixme provide a proper hierarchy
  include ZombieInterface

  def initialize(*args)
    @lurch_offset = 0
    super
  end

end
