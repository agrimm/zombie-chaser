require "test/unit"

module TestIntegrationHelper
  def output_text_for_command(command)
    output_file = IO.popen(command)
    output_text = output_file.read
    output_text
  end
end

class TestIntegration < Test::Unit::TestCase
  include TestIntegrationHelper

  EXAMPLE_DIRECTORY = "../exemplor-chaser-sample_target/"
  LARGE_TEST_EXAMPLE_DIRECTORY = "../bioruby-blessed/"
  BIT_BUCKET_FILENAME = "/dev/null" # Fixme make this windows-compatible?

  def setup
    raise "Don't have example directory" unless File.exist?(EXAMPLE_DIRECTORY)
    raise "Don't have large test example directory" unless File.exist?(LARGE_TEST_EXAMPLE_DIRECTORY)
    raise "Don't have bit bucket filename" unless File.exist?(BIT_BUCKET_FILENAME)
  end

  def test_exit_value_for_partial_test
    assert_equal false, system("ruby -I../exemplor-chaser-sample_target bin/zombie-chaser MyMath --tests ../exemplor-chaser-sample_target/partial_test_unit.rb --console > #{BIT_BUCKET_FILENAME}"), "Doesn't regard incomplete tests as a failure"
  end

  def test_exit_value_for_full_test
    assert_equal true, system("ruby -I../exemplor-chaser-sample_target bin/zombie-chaser MyMath --tests ../exemplor-chaser-sample_target/full_test_unit.rb --console > #{BIT_BUCKET_FILENAME}"), "Doesn't regard complete tests as a success"
  end

  def test_messages_arent_on_same_line_as_nethack_representation
    output_text = output_text_for_command("ruby -I../exemplor-chaser-sample_target bin/zombie-chaser MyMath --tests ../exemplor-chaser-sample_target/full_test_unit.rb --console")
    assert_no_match(/@.*The mutant didn't survive/, output_text, "Doesn't put messages on a new line")
  end

  def test_output_ends_with_newline
    output_text = output_text_for_command("ruby -I../exemplor-chaser-sample_target bin/zombie-chaser MyMath --tests ../exemplor-chaser-sample_target/full_test_unit.rb --console")
    assert_equal "\n", output_text[-1..-1], "Doesn't end with a newline, causing problems for command lines"
  end

  def test_console_width_configurable
    output_text = output_text_for_command("ruby -I../bioruby-blessed/lib/ bin/zombie-chaser Bio::Sequence::NA --test ../bioruby-blessed/test/unit/bio/sequence/test_na.rb --console --width 10")
    assert_no_match(/\.\.\.\.\.\.\.\.\.\.\./, output_text, "Doesn't allow console width to be configurable")
  end

end