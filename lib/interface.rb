class Interface
  attr_writer :human, :current_zombie

  def initialize
    @representations = []
    @current_zombie = nil
  end

  def current_representation
    if @current_zombie.nil?
      "." * human_successful_step_count + @human.current_symbol
    elsif human_successful_step_count > @current_zombie.successful_step_count
      "." * @current_zombie.successful_step_count + @current_zombie.current_symbol + "." * (@human.successful_step_count - @current_zombie.successful_step_count - 1) + @human.current_symbol
    else
      "." * @current_zombie.successful_step_count + @current_zombie.current_symbol
    end
  end

  def human_successful_step_count
    @human.successful_step_count
  end

  def something_happened
    @representations << current_representation
    display_representation(@representations.last)
  end

end

class NoInterface < Interface
  attr_reader :representations

  def display_representation(representation)
    #Do nothing
  end

  def finish
    #Do nothing
  end
end

class ConsoleInterface < Interface

  def display_representation(representation)
    print "\r", representation
    STDOUT.flush
    sleep 0.2
  end

  def finish
    puts
  end
end
