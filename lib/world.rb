require "human"
require "interface"

class World
  @interface_type = :gui_interface

  def self.interface_type=(interface_type); @interface_type = interface_type end
  def self.interface_type; @interface_type end

  attr_reader :interface

  def self.new_using_results(human_results, zombies_results)
    world = new(:no_interface)
    human = MockHuman.new_using_results(human_results, world)
    zombie_list = MockZombieList.new_using_results(zombies_results, world)
    world.set_human(human)
    world.set_zombie_list(zombie_list)
    world
  end

  def self.new_using_test_unit_handler(test_pattern)
    world = new(self.interface_type)
    human = Human.new_using_test_unit_handler(test_pattern, world)
    zombie_list = ZombieList.new_using_test_unit_handler(test_pattern, world)
    world.set_human(human)
    world.set_zombie_list(zombie_list)
    world
  end

  def initialize(interface_type)
    @human = nil
    @zombie_list = nil
    @interface = case interface_type
      when :console_interface then ConsoleInterface.new
      when :no_interface then NoInterface.new
      when :gui_interface then GuiInterface.new
    end
    @view_update_threads = nil
  end

  def set_human(human)
    raise "Already set" unless @human.nil?
    @human = human
    interface.human = human
  end

  def set_zombie_list(zombie_list)
    raise "Already set" unless @zombie_list.nil?
    @zombie_list = zombie_list
    @interface.zombie_list = zombie_list
  end

  def while_world_running
    @view_update_threads = Queue.new
    yield
    @view_update_threads.enq(:end_of_work)
    thread = @view_update_threads.deq
    until thread == :end_of_work
      thread.join
      thread = @view_update_threads.deq
    end
    @interface.finish_if_neccessary
  end

  def run_human
    @human.run
    ! @human.dead?
  end

  def run_next_zombie
    sleep 0.2
    zombie = @zombie_list.supply_next_zombie
    @view_update_threads.enq(Thread.new{zombie.build_view_queue})
    @view_update_threads.enq(Thread.new{zombie.update_view})
    zombie.run_tests
  end

  def something_happened
    @interface.something_happened
  end

  def sleep(duration)
    @interface.sleep(duration)
  end

  def notify_human_eaten
    @human.get_eaten
  end

  #Assumption: this is called after human is in a valid state
  def human_dead?
    @human.dead?
  end

  def no_living_zombies_apart_from_me?(desired_step_count, actor)
    @interface.no_living_zombies_apart_from_me?(desired_step_count, actor)
  end
end

