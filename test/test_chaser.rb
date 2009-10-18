$:.unshift(File.dirname(__FILE__) + '/fixtures')
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit/testcase'
require 'test/unit' if $0 == __FILE__
require 'test_unit_chaser'
require 'chased'

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

class ChaserTestCase < Test::Unit::TestCase
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
    @chaser = TestChaser.new("Chased", "add")
    chased = Chased.new
    assert_equal 5, chased.add(2,3), "method has been modified before it should have been"
    @chaser.modify_method
    assert_equal 10, chased.add(2,3), "method hasn't been modified"
    @chaser.unmodify_method
    assert_equal 5, chased.add(2,3), "method should be back to normal, but it isn't"
  end

  def test_modify_and_unmodify_string
    @chaser = TestChaser.new("Chased", "say_hello")
    chased = Chased.new
    assert_equal "G'day!", chased.say_hello, "method has been modified before it should have been"
    @chaser.modify_method
    assert_equal "l33t h4x0r", chased.say_hello, "method hasn't been modified"
    @chaser.unmodify_method
    assert_equal "G'day!", chased.say_hello, "method should be back to normal, but it isn't"
  end

  def test_modify_and_unmodify_class_method
    @chaser = TestChaser.new("Chased", "self.static_method")
    assert_equal "Zap!", Chased.static_method, "class method has been modified before it should have been"
    @chaser.modify_method
    assert_equal "l33t h4x0r", Chased.static_method, "class method hasn't been modified"
    @chaser.unmodify_method
    assert_equal "Zap!", Chased.static_method, "class method should be back to normal, but it isn't"
  end

end


