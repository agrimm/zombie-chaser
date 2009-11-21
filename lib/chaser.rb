require 'rubygems'
require 'timeout'

class String # :nodoc:
  def to_class
    split(/::/).inject(Object) { |klass, name| klass.const_get(name) }
  end
end

##
# Test Unit Sadism

class Chaser

  class Timeout < Timeout::Error; end

  ##
  # The version of Chaser you are using.

  VERSION = '0.0.4'

  ##
  # Is this platform MS Windows-like?

  WINDOZE = RUBY_PLATFORM =~ /mswin/

  ##
  # Path to the bit bucket.

  NULL_PATH = WINDOZE ? 'NUL:' : '/dev/null'

  ##
  # Class being chased

  attr_accessor :klass

  ##
  # Name of class being chased

  attr_accessor :klass_name

  ##
  # Method being chased

  attr_accessor :method

  ##
  # Name of method being chased

  attr_accessor :method_name

  ##
  # The original version of the method being chased

  attr_reader :old_method

  @@debug = false
  @@guess_timeout = true
  @@timeout = 60 # default to something longer (can be overridden by runners)

  def self.debug
    @@debug
  end

  def self.debug=(value)
    @@debug = value
  end

  def self.timeout=(value)
    @@timeout = value
    @@guess_timeout = false # We've set the timeout, don't guess
  end

  def self.guess_timeout?
    @@guess_timeout
  end

  ##
  # Creates a new Chaser that will chase +klass_name+ and +method_name+,
  # sending results to +reporter+.

  def initialize(klass_name = nil, method_name = nil, reporter = Reporter.new)
    @klass_name = klass_name
    @method_name = method_name.intern if method_name

    @klass = klass_name.to_class if klass_name

    @method = nil
    @reporter = reporter

    @mutated = false

    @failure = false
  end

  ##
  # Overwrite test_pass? for your own Chaser runner.

  def tests_pass?
    raise NotImplementedError
  end

  def run_tests
    if tests_pass? then
      record_passing_mutation
    else
      @reporter.report_test_failures
    end
  end

  ############################################################
  ### Running the script

  def validate
    @reporter.method_loaded(klass_name, method_name)

    begin
      modify_method
      timeout(@@timeout, Chaser::Timeout) { run_tests }
    rescue Chaser::Timeout
      @reporter.warning "Your tests timed out. Chaser may have caused an infinite loop."
    rescue Interrupt
      @reporter.warning 'Mutation canceled, hit ^C again to exit'
      sleep 2
    end

    unmodify_method # in case we're validating again. we should clean up.

    if @failure
      @reporter.report_failure
      false
    else
      @reporter.no_surviving_mutant
      true
    end
  end

  def record_passing_mutation
    @failure = true
  end

  def calculate_proxy_method_name(original_name)
    result = "__chaser_proxy__#{original_name}"
    character_renaming = {"[]" => "square_brackets", "^" => "exclusive_or",
    "=" => "equals", "&" => "ampersand", "*" => "splat", "+" => "plus",
    "-" => "minus", "%" => "percent", "~" => "tilde", "@" => "at",
    "/" => "forward_slash", "<" => "less_than", ">" => "greater_than"}
    character_renaming.each do |characters, renamed_string_portion|
      result.gsub!(characters, renamed_string_portion)
    end
    result
  end

  def unmodify_instance_method
    chaser = self
    @mutated = false
    chaser_proxy_method_name = calculate_proxy_method_name(@method_name)
    @klass.send(:define_method, chaser_proxy_method_name) do |block, *args|
      chaser.old_method.bind(self).call(*args) {|*yielded_values| block.call(*yielded_values)}
    end
  end

  def unmodify_class_method
    chaser = self
    @mutated = false
    chaser_proxy_method_name = calculate_proxy_method_name(clean_method_name)
    aliasing_class(@method_name).send(:define_method, chaser_proxy_method_name) do |block, *args|
      chaser.old_method.bind(self).call(*args) {|*yielded_values| block.call(*yielded_values)}
    end
  end

  # Ruby 1.8 doesn't allow define_method to handle blocks.
  # The blog post http://coderrr.wordpress.com/2008/10/29/using-define_method-with-blocks-in-ruby-18/
  # show that define_method has problems, and showed how to do workaround_method_code_string
  def modify_instance_method
    chaser = self
    @mutated = true
    @old_method = @klass.instance_method(@method_name)
    chaser_proxy_method_name = calculate_proxy_method_name(@method_name)
    workaround_method_code_string = <<-EOM
      def #{@method_name}(*args, &block)
        #{chaser_proxy_method_name}(block, *args)
      end
    EOM
    @klass.class_eval do
      eval(workaround_method_code_string)
    end
    @klass.send(:define_method, chaser_proxy_method_name) do |block, *args|
      original_value = chaser.old_method.bind(self).call(*args) do |*yielded_values|
        mutated_yielded_values = yielded_values.map{|value| chaser.mutate_value(value)}
        block.call(*mutated_yielded_values)
      end
      chaser.mutate_value(original_value)
    end
  end

  def modify_class_method
    chaser = self
    @mutated = true
    @old_method = aliasing_class(@method_name).instance_method(clean_method_name)
    chaser_proxy_method_name = calculate_proxy_method_name(clean_method_name)
    workaround_method_code_string = <<-EOM
      def #{@method_name}(*args, &block)
        #{chaser_proxy_method_name}(block, *args)
      end
    EOM
    @klass.class_eval do
      eval(workaround_method_code_string)
    end
    aliasing_class(@method_name).send(:define_method, chaser_proxy_method_name) do |block, *args|
      original_value = chaser.old_method.bind(self).call(*args) do |*yielded_values|
        mutated_yielded_values = yielded_values.map{|value| chaser.mutate_value(value)}
        block.call(*mutated_yielded_values)
      end
      chaser.mutate_value(original_value)
    end
  end

  def modify_method
    if method_name.to_s =~ /self\./
      modify_class_method
    else
      modify_instance_method
    end
  end

  def unmodify_method
    if method_name.to_s =~ /self\./ #TODO fix duplication. Give the test a name
      unmodify_class_method
    else
      unmodify_instance_method
    end
  end


  ##
  # Replaces the value with a random value.

  def mutate_value(value)
    case value
    when Fixnum, Float, Bignum
      value + rand_number
    when String
      rand_string
    when Symbol
      rand_symbol
    when Regexp
      Regexp.new(Regexp.escape(rand_string.gsub(/\//, '\\/')))
    when Range
      rand_range
    when NilClass, FalseClass
      rand_number
    when TrueClass
      false
    else
      nil
    end
  end

  ############################################################
  ### Convenience methods

  def aliasing_class(method_name)
    method_name.to_s =~ /self\./ ? class << @klass; self; end : @klass
  end

  def clean_method_name
    method_name.to_s.gsub(/self\./, '')
  end

  ##
  # Returns a random Fixnum.

  def rand_number
    (rand(100) + 1)*((-1)**rand(2))
  end

  ##
  # Returns a random String

  def rand_string
    size = rand(50)
    str = ""
    size.times { str << rand(126).chr }
    str
  end

  ##
  # Returns a random Symbol

  def rand_symbol
    letters = ('a'..'z').to_a + ('A'..'Z').to_a
    str = ""
    (rand(50) + 1).times { str << letters[rand(letters.size)] }
    :"#{str}"
  end

  ##
  # Returns a random Range

  def rand_range
    min = rand(50)
    max = min + rand(50)
    min..max
  end

  ##
  # Suppresses output on $stdout and $stderr.

  def silence_stream
    return yield if @@debug

    begin
      dead = File.open(Chaser::NULL_PATH, "w")

      $stdout.flush
      $stderr.flush

      oldstdout = $stdout.dup
      oldstderr = $stderr.dup

      $stdout.reopen(dead)
      $stderr.reopen(dead)

      result = yield

    ensure
      $stdout.flush
      $stderr.flush

      $stdout.reopen(oldstdout)
      $stderr.reopen(oldstderr)
      result
    end
  end

  class Reporter
    def method_loaded(klass_name, method_name)
      info "#{klass_name}\##{method_name} loaded"
    end

    def warning(message)
      puts "!" * 70
      puts "!!! #{message}"
      puts "!" * 70
      puts
    end

    def info(message)
      puts "*"*70
      puts "***  #{message}"
      puts "*"*70
      puts
    end

    def report_failure
      puts
      puts "The affected method didn't cause test failures."
      puts
    end

    def no_surviving_mutant
      puts "The mutant didn't survive. Cool!\n\n"
    end

    def report_test_failures
      puts "Tests failed -- this is good" if Chaser.debug
    end
  end

end

