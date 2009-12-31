require "test/unit/collector/objectspace"
require "test/unit/ui/testrunnermediator"

class TestUnitHandler
  attr_reader :test_suite_size

  def initialize(test_pattern)
    @actor = nil
    raise "Error: can't detect any files in test pattern \"#{test_pattern} (Don't forget to use forward slashes even in Windows)" if Dir.glob(test_pattern).empty?
    Dir.glob(test_pattern).each {|test| require test} #In heckle, this is separated out
    obj_sp = Test::Unit::Collector::ObjectSpace.new
    test_suite = Test::Unit::TestSuite.new("Mutation slayer test suite")
    test_suite << obj_sp.collect
    @test_suite_size = test_suite.size
    @test_runner_mediator =  Test::Unit::UI::TestRunnerMediator.new(test_suite)
    @test_runner_mediator.add_listener(Test::Unit::TestResult::FAULT) {test_failed}
    @test_runner_mediator.add_listener(Test::Unit::TestCase::FINISHED) {test_finished}
  end

  def run
    catch(:stop_test_runner) do
      @test_runner_mediator.run_suite
    end
  end

  def test_failed
    @actor.notify_failing_step
    sleep 0.5
    throw :stop_test_runner
  end

  def test_finished
    sleep 0.1 #Hack to avoid it being too quick
    @actor.notify_passing_step
  end

  def set_actor(actor)
    raise "Actor already set!" unless @actor.nil?
    @actor = actor
  end

end

class MockTestHandler

  def initialize(results)
    @results = results
    @actor = nil
  end

  def test_suite_size
    @results.size
  end

  def run
    @results.each do |result|
      case result
      when :pass
        @actor.notify_passing_step
      when :failure
        @actor.notify_failing_step
        break
      else
        raise "Unknown result"
      end
    end
  end

  def set_actor(actor)
    raise "Actor already set!" unless @actor.nil?
    @actor = actor
  end
end
