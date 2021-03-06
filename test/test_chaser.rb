require 'test/unit/testcase'
require 'test/unit' if $0 == __FILE__
require 'zombie-chaser/zombie_test_chaser'
require 'fixtures/chased'

class TestChaser < Chaser
  def rand(*args)
    5
  end

  def rand_string
    "l33t h4x0r"
  end

  def rand_number(*args)
    5
  end

  def rand_symbol
    :"l33t h4x0r"
  end
end

module ChaserTestCaseHelper
  def create_chaser(klass_name, method_name)
    # Fixme the third variable is for a reporter. The fact that it's not being used suggests that we're not using
    # the whole of the TestChaser, and ought to split it up into smaller classes
    TestChaser.new(klass_name, method_name, nil)
  end
end

class ChaserTestCase < Test::Unit::TestCase
  include ChaserTestCaseHelper

  unless defined? Mini then
    undef_method :default_test
    alias :refute_equal :assert_not_equal
  end

  def setup
  end

  def teardown
    @chaser.unmodify_method if defined?(@chaser) && @chaser
  end

  def test_unmodified_behaves_as_expected
    chased = Chased.new
    assert_equal 5, chased.add(2,3), "Unmodified version should equal 5"
  end

  def test_modify_and_unmodify_instance_method
    @chaser = create_chaser("Chased", "add")
    chased = Chased.new
    assert_equal 5, chased.add(2,3), "method has been modified before it should have been"
    @chaser.modify_method
    assert_equal 10, chased.add(2,3), "method hasn't been modified"
    @chaser.unmodify_method
    assert_equal 5, chased.add(2,3), "method should be back to normal, but it isn't"
  end

  def test_modify_and_unmodify_string
    @chaser = create_chaser("Chased", "say_hello")
    chased = Chased.new
    assert_equal "G'day!", chased.say_hello, "method has been modified before it should have been"
    @chaser.modify_method
    assert_equal "l33t h4x0r", chased.say_hello, "method hasn't been modified"
    @chaser.unmodify_method
    assert_equal "G'day!", chased.say_hello, "method should be back to normal, but it isn't"
  end

  def test_modify_and_unmodify_class_method
    @chaser = create_chaser("Chased", "self.static_method")
    assert_equal "Zap!", Chased.static_method, "class method has been modified before it should have been"
    @chaser.modify_method
    assert_equal "l33t h4x0r", Chased.static_method, "class method hasn't been modified"
    @chaser.unmodify_method
    assert_equal "Zap!", Chased.static_method, "class method should be back to normal, but it isn't"
  end

  def test_pass_blocks_on_in_instance_methods
    @chaser = create_chaser("Chased", "block_yielding_instance_method")
    chased = Chased.new
    assert_equal [2,4,6], chased.block_using_instance_method, "block yielding instance method has been modified before it should have been"
    @chaser.modify_method
    assert_equal [12, 14, 16], chased.block_using_instance_method, "yielded values haven't been modified"
    @chaser.unmodify_method
    assert_equal [2,4,6], chased.block_using_instance_method, "block yielding instance method has been modified before it should have been"
  end

  def test_pass_blocks_on_in_class_methods
    @chaser = create_chaser("Chased", "self.block_yielding_class_method")
    assert_equal [2,4], Chased.block_using_class_method, "block yielding class method has been modified before it should have been"
    @chaser.modify_method
    assert_equal [12, 14], Chased.block_using_class_method, "yielded values haven't been modified"
    @chaser.unmodify_method
    assert_equal [2,4], Chased.block_using_class_method, "block yielding class method has been modified before it should have been"
  end

  def test_handle_funny_characters_in_instance_method_names
    @chaser = create_chaser("Chased", "[]")
    chased = Chased.new
    assert_equal 2, chased[1], "Original doesn't work"
    @chaser.modify_method
    assert_equal 7, chased[1], "Modified doesn't work"
    @chaser.unmodify_method
    assert_equal 2, chased[1], "Modified then unmodified doesn't work"
  end

  def test_handle_funny_characters_in_class_method_names
    @chaser = create_chaser("Chased", "self.[]")
    assert_equal 2, Chased[1], "Original doesn't work"
    @chaser.modify_method
    assert_equal 7, Chased[1], "Modified doesn't work"
    @chaser.unmodify_method
    assert_equal 2, Chased[1], "Modified then unmodified doesn't work"
  end

  def test_more_funny_characters
    assert_nothing_raised("Can't handle certain characters") do
      @chaser = create_chaser("Chased", "question?")
      chased = Chased.new
      chased.question?
      @chaser.modify_method
      chased.question?
      @chaser.unmodify_method
      chased.question?
    end

    assert_nothing_raised("Can't handle equal signs") do
      @chaser = create_chaser("Chased", "foo=")
      chased = Chased.new
      chased.foo= 1
      @chaser.modify_method
      chased.foo = 2
      @chaser.unmodify_method
      chased.foo = 3
    end
  end
end


class ZombieTestChaserCase < Test::Unit::TestCase
  def test_detects_invalid_glob
    incorrect_glob = 'test\test_chaser.rb'
    assert_raise(RuntimeError, "Can't detect an incorrect glob") do
      TestUnitHandler.new(incorrect_glob)
    end
  end
end
