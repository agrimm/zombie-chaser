$: << "lib"

require "test/unit"
require "world"

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

  def assert_that_representations_do_not_include(unexpected_representation, human_results, zombies_results, failure_message)
    world = create_world(human_results, zombies_results)
    actual_representations = world.interface.representations
    assert_equal false, actual_representations.include?(unexpected_representation), failure_message + ": Didn't expect #{unexpected_representation}, got #{actual_representations.inspect}"
  end

  def assert_that_human_deadness_is(human_expected_to_die, human_results, zombies_results, failure_message)
    world = create_world(human_results, zombies_results)
    assert_equal human_expected_to_die, world.human_dead?, failure_message
  end

  def create_world(human_results, zombies_results = [])
    world = World.new_using_results(human_results, zombies_results)
    human_survives = world.run_human
    zombies_results.size.times {world.run_next_zombie} if human_survives
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

end

class TestConsoleInterface < Test::Unit::TestCase
  include TestHumanHelper

  def test_excessive_tests_dont_make_it_run_off_the_page
    human_results = [:pass] * 500
    zombies_results = [[:pass, :failure]]
    expected_representations = ["Z" + "." * 77 + "@"] #Having 80 characters in a line doesn't work
    failure_message = "Doesn't handle large number of tests properly"
    assert_that_representations_include_these_representations(expected_representations, human_results, zombies_results, failure_message)
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
