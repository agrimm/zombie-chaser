require "test/unit/collector/objectspace"
require "test/unit/ui/testrunnermediator"

require "thread"

class TestUnitHandler
  attr_reader :test_suite_size, :result_queue

  def initialize(test_pattern)
    raise "Error: can't detect any files in test pattern \"#{test_pattern} (Don't forget to use forward slashes even in Windows)" if Dir.glob(test_pattern).empty?
    Dir.glob(test_pattern).each {|test| require test} #In heckle, this is separated out
    obj_sp = Test::Unit::Collector::ObjectSpace.new
    test_suite = Test::Unit::TestSuite.new("Mutation slayer test suite")
    test_suite << obj_sp.collect
    @test_suite_size = test_suite.size
    @test_runner_mediator =  Test::Unit::UI::TestRunnerMediator.new(test_suite)
    @test_runner_mediator.add_listener(Test::Unit::TestResult::FAULT) {test_failed}
    @test_runner_mediator.add_listener(Test::Unit::TestCase::FINISHED) {test_finished}
    @result_queue = ResultQueue.new
  end

  def run
    catch(:stop_test_runner) do
      @test_runner_mediator.run_suite
    end
    @result_queue.enq(:end_of_work)
    @failure_encountered
  end

  def test_failed
    @result_queue.enq(:failure)
    @failure_encountered = true
    throw :stop_test_runner
  end

  def test_finished
    @result_queue.enq(:pass)
  end

end

class MockTestHandler
  attr_reader :result_queue

  def initialize(results)
    @results = results
    @result_queue = ResultQueue.new
    @failure_encountered = false
  end

  def test_suite_size
    @results.size
  end

  def run
    @results.each do |result|
      @result_queue.enq(result)
      if result == :failure
        @failure_encountered = true
        break
      end
    end
    @result_queue.enq(:end_of_work)
    @failure_encountered
  end

end

class ResultQueue
  def initialize
    @result_queue = Queue.new
  end

  def enq(result)
    @result_queue << result
  end

  def empty?
    @result_queue.empty?
  end

  def deq
    @result_queue.deq
  end
end
