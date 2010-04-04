$: << "lib"

require "test/unit"
require "world"
require "timeout"

module TestHumanHelper
  def assert_that_representations_include(expected_representation, human_results, failure_message)
    world = create_world(human_results)
    actual_representations = world.interface.representations
    assert actual_representations.include?(expected_representation), failure_message + "Expected #{expected_representation}, got #{actual_representations.inspect}"
  end

  def assert_that_representations_include_these_representations(expected_representations, human_results, zombies_results, failure_message)
    world = create_world(human_results, zombies_results)
    actual_representations = world.interface.representations
    expected_representations.each do |expected_representation|
      assert actual_representations.include?(expected_representation), failure_message + ": Expected #{expected_representation}, got #{actual_representations.inspect}"
    end
  end

  def assert_adjusted_width_representations_include_representations(expected_representations, human_results, zombies_results, console_width, failure_message)
    world = create_world_with_set_console_width(human_results, zombies_results, console_width)
    actual_representations = world.interface.representations
    expected_representations.each do |expected_representation|
      assert actual_representations.include?(expected_representation), failure_message + ": Expected #{expected_representation}, got #{actual_representations.inspect}"
    end
  end

  def assert_that_representations_do_not_include(unexpected_representation, human_results, zombies_results, failure_message)
    world = create_world(human_results, zombies_results)
    actual_representations = world.interface.representations
    assert_equal false, actual_representations.include?(unexpected_representation), failure_message + ": Didn't expect #{unexpected_representation}, got #{actual_representations.inspect}"
  end

  def assert_that_representations_include_regexp_match(expected_regexp, human_results, zombies_results, failure_message)
    world = create_world(human_results, zombies_results)
    actual_representations = world.interface.representations
    assert actual_representations.any?{|actual_representation| actual_representation =~ expected_regexp}, failure_message + ": Expected #{expected_regexp.inspect} would match something in #{actual_representations.inspect}"
  end

  def assert_that_representations_do_not_include_regexp_match(unexpected_regexp, human_results, zombies_results, failure_message)
    world = create_world(human_results, zombies_results)
    actual_representations = world.interface.representations
    assert_equal false, actual_representations.any?{|actual_representation| puts actual_representation if actual_representation =~ unexpected_regexp; actual_representation =~ unexpected_regexp}, failure_message + ": Didn't expect #{unexpected_regexp.inspect} would match something in #{actual_representations.inspect}"
  end

  def assert_that_human_deadness_is(human_expected_to_die, human_results, zombies_results, failure_message)
    world = create_world(human_results, zombies_results)
    assert_equal human_expected_to_die, world.human_dead?, failure_message
  end

  def assert_that_counts_are(expected_counts, human_results, zombies_results, failure_message)
    world = World.new_using_results(human_results, zombies_results)
    actual_counts = Hash.new(0)
    world.while_world_running do
      assert world.run_human, "Human unexpectedly died"
      zombies_results.size.times do
        begin
          # Chaser#validate returns true if chaser-proof, and false if mutations to it still pass its unit tests
          # Hence the "not" in the next line
          result = (not world.run_next_zombie)
        rescue Timeout::Error
          result = true
        end
        actual_counts[result] += 1
      end
    end
    assert_equal expected_counts, actual_counts, failure_message
  end

  def assert_does_not_deadlock(human_results, zombies_results, failure_message)
    assert_nothing_raised(failure_message) do
      timeout(1) do
        world = create_world(human_results, zombies_results)
      end
    end
  end

  def create_world(human_results, zombies_results = [])
    world = World.new_using_results(human_results, zombies_results)
    world.while_world_running do
      human_survives = world.run_human
      if human_survives
        zombies_results.size.times do
          begin
            world.run_next_zombie
          rescue Timeout::Error
            #Don't worry about it
          end
        end
      end
    end
    world
  end
end

class TestHuman < Test::Unit::TestCase
  include TestHumanHelper

  def test_human_single_success
    human_results = [:pass]
    failure_message = "Can't handle single success"
    assert_that_representations_include(".@", human_results, failure_message)
  end

  def test_human_single_failure
    human_results = [:failure]
    failure_message = "Can't handle single failure"
    assert_that_representations_include("+", human_results, failure_message)
  end

  def test_human_two_successes
    human_results = [:pass, :pass]
    expected_representations = ["@", ".@", "..@"]
    failure_message = "Needs to be able to do multiple steps"
    #This'll run the simulation three times. Optimize if neccessary (it isn't yet)
    expected_representations.each do |expected_representation|
      assert_that_representations_include(expected_representation, human_results, failure_message)
    end
  end

  def test_human_success_failure
    human_results = [:pass, :failure]
    expected_representation = ".+"
    failure_message = "Can't handle success and failure"
    assert_that_representations_include(expected_representation, human_results, failure_message)
  end

  def test_human_success_failure_success
    human_results = [:pass, :failure, :pass]
    expected_representation = ".+"
    failure_message = "Can't handle success and failure"
    assert_that_representations_include(expected_representation, human_results, failure_message)
  end

  def test_human_exploding
    human_results = [:pass, :failure]
    expected_representation = ".*"
    failure_message = "Doesn't represent the human exploding"
    assert_that_representations_include(expected_representation, human_results, failure_message)
  end

end

class TestZombie < Test::Unit::TestCase
  include TestHumanHelper

  def test_human_surviving_zombie_slaying
    human_results = [:pass, :pass]
    zombies_results = [[:failure]]
    expected_representations = ["..@", "*.@"]
    failure_message = "Can't represent a zombie slaying."
    assert_that_representations_include_these_representations(expected_representations, human_results, zombies_results, failure_message)
  end

  def test_human_surviving_zombie_slaying2
    human_results = [:pass, :pass, :pass]
    zombies_results = [[:pass, :failure]]
    expected_representations = ["...@", "Z..@", ".*.@"]
    failure_message = "Can't represent a zombie slaying."
    assert_that_representations_include_these_representations(expected_representations, human_results, zombies_results, failure_message)
  end

  #Describes existing behaviour, but added to ensure a future commit works properly
  def test_zombies_dont_appear_if_human_doesnt_survive_unit_tests
    human_results = [:pass, :failure]
    zombies_results = [[:pass, :failure]]
    unexpected_representation = "Z+"
    failure_message = "Doesn't stop after failed unmutated unit tests"
    assert_that_representations_do_not_include(unexpected_representation, human_results, zombies_results, failure_message)
  end

  def test_corpse_littered_landscape
    human_results = [:pass, :pass, :pass]
    zombies_results = [[:pass, :failure],[:failure]]
    expected_representations = ["++.@"]
    failure_message = "Can't display a corpse littered landscape"
    assert_that_representations_include_these_representations(expected_representations, human_results, zombies_results, failure_message)
  end

  def test_multiple_living_zombies_visible
    human_results = [:pass] * 10
    zombies_results = [[:pass]* 8 + [:failure]] * 5
    expected_regexp = /ZZ/
    failure_message = "Can't display multiple zombies at once"
    assert_that_representations_include_regexp_match(expected_regexp, human_results, zombies_results, failure_message)
  end

  def test_timeouts_in_test_dont_cause_frozen_zombies
    human_results = [:pass]
    zombies_results = [[:timeout]]
    failure_message = "Doesn't handle timeouts"
    assert_does_not_deadlock(human_results, zombies_results, failure_message)
  end
end

class TestConsoleInterface < Test::Unit::TestCase
  include TestHumanHelper

  #Put inside of this test case so that only things with this test case's teardown can use it
  def create_world_with_set_console_width(human_results, zombies_results, width)
    ConsoleInterface.width = width
    world = create_world(human_results, zombies_results)
    world
  end

  def test_excessive_tests_dont_make_it_run_off_the_page
    human_results = [:pass] * 500
    zombies_results = [[:pass, :failure]]
    expected_representations = ["Z" + "." * 77 + "@"] #Having 80 characters in a line doesn't work
    failure_message = "Doesn't handle large number of tests properly"
    assert_that_representations_include_these_representations(expected_representations, human_results, zombies_results, failure_message)
  end

  def test_console_width_configurable
    human_results = [:pass] * 500
    zombies_results = [[:pass, :failure]]
    console_width = 11
    expected_representations = ["Z" + "." * 9 + "@"]
    failure_message = "Doesn't allow console width to be configurable"
    assert_adjusted_width_representations_include_representations(expected_representations, human_results, zombies_results, console_width, failure_message)
  end

  def test_zombies_do_not_trample_non_dead_zombies
    human_results = [:pass, :pass]
    zombies_results = [[:pass, :failure], [:pass, :pass]]
    expected_representations = ["Z*@", "Z+@"]
    failure_message = "Zombies are trampling on non-dead zombies"
    assert_that_representations_include_these_representations(expected_representations, human_results, zombies_results, failure_message)
  end

  def dont_test_zombies_do_not_collide
    human_results = [:pass] * 10
    zombies_results = [[:pass] * 10, [:pass] * 10]
    unexpected_regexp = /\A\.\.+Z\.+\@/ #Only one square with zombies, the second zombie should have appeared by now, and the human hasn't been eaten
    failure_message = "Zombies are sharing the same square"
    100.times do |i|
      assert_that_representations_do_not_include_regexp_match(unexpected_regexp, human_results, zombies_results, failure_message + "(attempt #{i})")
    end
  end

  def test_multiple_successful_zombies_do_not_deadlock
    human_results = [:pass] * 2
    zombies_results = [[:pass] * 2] * 2
    failure_message = "Multiple successful zombies deadlock (pardon the pun)"
    assert_does_not_deadlock(human_results, zombies_results, failure_message)
  end

  #Confirming existing behaviour
  def test_zombie_does_not_deadlock_when_console_position_adjusted
    ConsoleInterface.width = 10
    human_results = [:pass] * 25
    zombies_results = [[:pass]*25]
    failure_message = "A zombie that isn't changing squares because of width limitations deadlocks (pardon the pun)"
    assert_does_not_deadlock(human_results, zombies_results, failure_message)
  end

  def teardown
    ConsoleInterface.width = 79
  end

end

class TestZombieHumanInteraction < Test::Unit::TestCase
  include TestHumanHelper

  def test_zombies_eat_human
    human_results = [:pass, :pass]
    zombies_results = [[:pass, :pass]]
    human_expected_to_die = true
    failure_message = "Human not eaten"
    assert_that_human_deadness_is human_expected_to_die, human_results, zombies_results, failure_message
  end
end

class TestResultsReporting < Test::Unit::TestCase
  include TestHumanHelper

  def test_killed_zombies_reported_as_success
    human_results = [:pass]
    zombies_results = [[:failure]]
    expected_counts = {true=>1}
    failure_message = "All zombies killed not regarded as all good"
    assert_that_counts_are expected_counts, human_results, zombies_results, failure_message
  end

  def test_unkilled_zombies_reported_as_failure
    human_results = [:pass]
    zombies_results = [[:pass]]
    expected_counts = {false => 1}
    failure_message = "Unkilled zombie not regarded as a problem"
    assert_that_counts_are expected_counts, human_results, zombies_results, failure_message
  end

  def test_timeouts_reported_as_success
    human_results = [:pass]
    zombies_results = [[:timeout]]
    expected_counts = {true => 1}
    failure_message = "Zombie causing timeout not regarded as all good"
    assert_that_counts_are expected_counts, human_results, zombies_results, failure_message
  end

end
