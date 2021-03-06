require "monitor"

class Interface
  attr_writer :human, :zombie_list

  def sleep(duration)
    super
  end

  def finish_if_neccessary
  end

  def interface_puts(*args)
    puts(*args)
    STDOUT.flush
  end
end

class ConsoleInterface < Interface
  @width = 79 #Having a value of 80 causes problems for Windows console sessions.

  def self.width=(width); @width = width end
  def self.width; @width end

  def initialize
    @representations = []
    @zombie_list = nil
    @progress_text_being_printed = false
    @output_lock = Monitor.new
  end

  def current_representation
    result = "." * human_position + @human.current_symbol
    unless @zombie_list.nil?
      @zombie_list.each_zombie do |zombie|
        position = adjust_for_screen_width(zombie.successful_step_count)
        result[position..position] = zombie.current_symbol
      end
    end
    result
  end
  private :current_representation

  def something_happened
    @output_lock.synchronize do
      @representations << current_representation
      display_representation(@representations.last)
    end
  end

  def display_representation(representation)
    print "\r", representation
    @progress_text_being_printed = true
    STDOUT.flush
  end
  private :display_representation

  def interface_puts(*args)
    @output_lock.synchronize do
      print_newline_if_neccessary
      super
    end
  end

  def human_position
    adjust_for_screen_width(@human.successful_step_count)
  end
  private :human_position

  def maximum_position
    ConsoleInterface.width - 1 #Subtract one as position is zero-indexed
  end
  private :maximum_position

  def adjust_for_screen_width(step_count)
    (step_count * 1.0 * maximum_position / [@human.test_suite_size, maximum_position].max).round
  end
  private :adjust_for_screen_width

  def no_living_zombies_apart_from_me?(desired_step_count, actor)
    desired_position = adjust_for_screen_width(desired_step_count)
    return true if desired_position == adjust_for_screen_width(0) #Hack to allow multiple zombies at the start
    return true if desired_position == adjust_for_screen_width(@human.test_suite_size) #Always room for one more at the dinner table!
    return true if desired_position == adjust_for_screen_width(actor.successful_step_count) #In case there's no advancement involved, and there's multiple zombies in a square even though they shouldn't be
    @zombie_list.each_zombie do |zombie|
      next if zombie.equal? actor #Only checking for collisions with other actors, not with itself
      next if zombie.dead?
      zombie_position = adjust_for_screen_width(zombie.successful_step_count)
      #raise if adjust_for_screen_width(actor.successful_step_count) == zombie_position
      return false if zombie_position == desired_position
    end
    true
  end

  def print_newline_if_neccessary
    if @progress_text_being_printed
      puts
      @progress_text_being_printed = false
    end
  end
  private :print_newline_if_neccessary

  def finish_if_neccessary
    @output_lock.synchronize do
      print_newline_if_neccessary
    end
  end

end

class NoInterface < ConsoleInterface
  attr_reader :representations

  def display_representation(representation)
    #Do nothing
  end

  #No need to sleep for a mock interface
  def sleep(duration)
    super(duration/1000.0) * 1000.0 #Not sure if it's needed, but just to be on the safe side
  end
end

class GuiInterface < Interface

  def initialize
    @window = Window.new
    #Actor.window = @window #Fixme why can't this do the trick?
    Human.window = @window
    Zombie.window = @window
    @window_showing_thread = Thread.new {@window.show}
  end

  #Doesn't need to be used, as window updates 60 times a second anyway
  def something_happened
  end

  def human=(human)
    @window.human = human
  end

  def zombie_list=(zombie_list)
    @window.zombie_list = zombie_list
  end

  def no_living_zombies_apart_from_me?(desired_step_count, actor)
    @window.no_living_zombies_apart_from_me?(desired_step_count, actor)
  end

  def finish_if_neccessary
    @window_showing_thread.join
  end
end
