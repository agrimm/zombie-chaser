class Interface
  attr_writer :human, :zombie_list

  def sleep(duration)
    super
  end
end

class ConsoleInterface < Interface

  def initialize
    @representations = []
    @zombie_list = nil
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

  def something_happened
    @representations << current_representation
    display_representation(@representations.last)
  end

  def display_representation(representation)
    print "\r", representation
    STDOUT.flush
    sleep 0.2
  end

  def human_position
    adjust_for_screen_width(@human.successful_step_count)
  end

  def maximum_position
    78 #Fixme make configurable
  end

  def adjust_for_screen_width(step_count)
    (step_count * 1.0 * maximum_position / [@human.test_suite_size, maximum_position].max).round
  end

end

class NoInterface < ConsoleInterface
  attr_reader :representations

  def display_representation(representation)
    #Do nothing
  end

  #No need to sleep for a mock interface
  def sleep(duration)
    0 #Number of seconds slept
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

end
