require "test/unit/collector/objectspace"
require "test/unit/ui/testrunnermediator"

class TestUnitHandler
  attr_reader :results

  def initialize(test_pattern, human)
    @human = human
    raise "Error: can't detect any files in test pattern \"#{test_pattern} (Don't forget to use forward slashes even in Windows)" if Dir.glob(test_pattern).empty?
    Dir.glob(test_pattern).each {|test| require test} #In heckle, this is separated out
    @finished = false
    @results = []
    @step_count = 0
    obj_sp = Test::Unit::Collector::ObjectSpace.new
    test_suite = Test::Unit::TestSuite.new("Mutation slayer test suite")
    test_suite << obj_sp.collect
    @test_runner_mediator =  Test::Unit::UI::TestRunnerMediator.new(test_suite)
    @test_runner_mediator.add_listener(Test::Unit::TestResult::FAULT) {test_failed}
    @test_runner_mediator.add_listener(Test::Unit::TestCase::FINISHED) {test_finished}

  end

  def run
    catch (:stop_test_runner) do
      @test_runner_mediator.run_suite
    end
  end

  def test_failed
    @results << :failure
    @human.notify_failing_step
    throw :stop_test_runner
  end

  def test_finished
    @results << :pass
    @human.notify_passing_step
  end

end
