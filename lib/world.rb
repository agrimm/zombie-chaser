require "human"
require "interface"

class World
  attr_reader :representations, :interface

  def self.new_using_results(human_results, zombies_results)
    world = new(:no_interface)
    human = MockHuman.new_using_results(human_results, world)
    zombie_list = MockZombieList.new_using_results(zombies_results, world)
    world.set_human(human)
    world.set_zombie_list(zombie_list)
    world
  end

  def self.new_using_test_unit_handler(test_pattern)
    world = new(:console_interface)
    human = Human.new_using_test_unit_handler(test_pattern, world)
    zombie_list = MockZombieList.new_using_results([], world) #Fixme
    world.set_human(human)
    world.set_zombie_list(zombie_list)
    world.set_test_pattern(test_pattern)
    world
  end

  def initialize(interface_type)
    @human = nil
    @current_zombie = nil
    @zombie_list = nil
    @test_pattern = nil
    @interface = case interface_type
      when :console_interface then ConsoleInterface.new
      when :no_interface then NoInterface.new
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

  def set_test_pattern(test_pattern)
    raise "Already set" unless @test_pattern.nil?
    @test_pattern = test_pattern
  end

  def run
    run_human
    until (@human.dead? or @zombie_list.all_slain?)
      run_zombie(@zombie_list.supply_next_zombie)
    end
    @interface.finish
  end

  def run_human
    @human.run
    @human.finish_dying if @human.dying?
    ! @human.dead?
  end

  def create_zombie_using_test_unit_handler
    raise "@test_pattern not defined?" if @test_pattern.nil?
    zombie = Zombie.new_using_test_unit_handler(@test_pattern, self)
  end

  def run_zombie(zombie)
    @current_zombie = zombie
    @interface.current_zombie = zombie
    @current_zombie.run
  end

  def something_happened
    @interface.something_happened
  end

end

