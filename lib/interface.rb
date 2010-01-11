class Interface
  attr_writer :human, :current_zombie

  def sleep(duration)
    super
  end
end

class ConsoleInterface < Interface

  def initialize
    @representations = []
    @current_zombie = nil
  end

  def current_representation
    result = "." * human_position + @human.current_symbol
    unless @current_zombie.nil?
      position = zombie_position
      result[position..position] = @current_zombie.current_symbol
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

  def zombie_position
    adjust_for_screen_width(@current_zombie.successful_step_count)
  end

  def adjust_for_screen_width(step_count)
    max_position = 78.0
    (step_count * max_position / [@human.test_suite_size, max_position].max).round
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

  def current_zombie=(current_zombie)
    @window.current_zombie = current_zombie
  end

end
