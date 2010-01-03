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
    @current_zombie = nil
    @zombie_list = nil
    @interface = case interface_type
      when :console_interface then ConsoleInterface.new
      when :no_interface then NoInterface.new
      when :gui_interface then GuiInterface.new
    end
  end

  def set_human(human)
    raise "Already set" unless @human.nil?
    @human = human
    interface.human = human
  end

  def set_zombie_list(zombie_list)
    raise "Already set" unless @zombie_list.nil?
    @zombie_list = zombie_list
  end

  #FIXME currently only used by the unit tests. It is equivalent to ZombieTestChaser.validate
  def run
    run_human
    unless @human.dead?
      run_next_zombie until @zombie_list.all_zombies_run?
    end
    @interface.finish
  end

  def run_human
    @human.run
    @human.finish_dying if @human.dying?
    ! @human.dead?
  end

  def run_next_zombie
    run_zombie(@zombie_list.supply_next_zombie)
  end

  def run_zombie(zombie)
    @current_zombie = zombie
    @interface.current_zombie = zombie
    sleep 0.2
    @current_zombie.run
    if @current_zombie.dying?
      @current_zombie.finish_dying
    else
      @current_zombie.eat(@human)
      sleep 1
    end
    ! @current_zombie.dead?
  end

  def something_happened
    @interface.something_happened
  end

  def sleep(duration)
    @interface.sleep(duration)
  end
end

