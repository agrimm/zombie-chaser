class NoInterface
  def display_representation(representation)
    #Do nothing
  end

  def finish
    #Do nothing
  end
end

class ConsoleInterface

  def display_representation(representation)
    print "\r", representation
    STDOUT.flush
    sleep 0.2
  end

  def finish
    puts
  end
end
