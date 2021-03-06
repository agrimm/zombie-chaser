begin
  require 'gosu'
rescue LoadError => e
  require 'ostruct'
  module Gosu
    class Window
      attr_accessor :caption, :grid
      def initialize(one, two, three)
        abort "Gosu not installed. Please use the --console option, or install gosu"
      end
    end

    class Image
      def initialize(*args)
      end
    end
  end
end

class ZIndex
  LAYERS = [:world, :dead, :actor, :attacking, :overlay]

  def self.for(type); LAYERS.index(type) end
end

class Actor

  def self.window=(window); @window = window end
  def self.window; @window end

  def self.sprites
    @sprites ||=  Dir[File.join(File.dirname(__FILE__),'sprites/*.png')].inject({}) do |sprites,f|
      sprite = File.basename(f,'.*').split('-')
      sprites[sprite.first] ||= {}
      sprites[sprite.first][sprite.last] = Gosu::Image.new(window, f, false)
      sprites
    end
  end

  def image
    #self.class.sprites['robot']['idle'] #FIXME adjust this to indicate human versus zombie, and status of alive, dying or dead
    self.class.sprites[actor_type][actor_state]
  end

  def actor_type
    raise NotImplementedError
  end

  def draw
    raise "actor is off the screen" unless (x > 0 and x < self.class.window.width and y > 0 and y < self.class.window.height)
    image.draw_rot(x, y, z, actor_direction)
  end

  def calculate_x(successful_step_count)
    preferred_step_size = 10
    max_distance = ([Window.width, Window.height].min / 2) - preferred_step_size
    (Window.width / 2) + Math::sin(@angle) * ((test_suite_size - successful_step_count) * preferred_step_size) * [1, max_distance * 1.0 / (test_suite_size * preferred_step_size)].min
  end

  def calculate_y(successful_step_count)
    preferred_step_size = 10
    max_distance = ([Window.width, Window.height].min / 2) - preferred_step_size
    ((Window.height / 2) + Math::cos(@angle) * ((test_suite_size - successful_step_count) * preferred_step_size) * [1, max_distance * 1.0 / (test_suite_size * preferred_step_size)].min)
  end

  def x
    calculate_x(@successful_step_count)
  end

  def y
    calculate_y(@successful_step_count)
  end

  def z
    case actor_state
    when "dead" then ZIndex.for(:dead)
    when "attacking" then ZIndex.for(:attacking)
    when "moving" then ZIndex.for(:actor)
    when "dying" then ZIndex.for(:actor)
    else raise "Unknown state"
    end
  end

  def window
    self.class.window
  end
end

class Window < Gosu::Window
  @width = 400
  @height = 300

  def self.width=(width); @width = width end
  def self.width; @width end

  def self.height=(height); @height = height end
  def self.height; @height end

  attr_accessor :grid
  attr_writer :human, :zombie_list

  def initialize
    super(self.class.width, self.class.height, false)

    self.caption = 'Zombie-chaser'
    self.grid = 1

    @grass     = Gosu::Image.new(self, File.join(File.dirname(__FILE__),'tiles/grass.png'), true)
    @shrubbery = Gosu::Image.new(self, File.join(File.dirname(__FILE__),'tiles/shrubbery.png'), true)
  end

  def draw
    draw_scenery
    draw_human
    draw_zombies
  end

  def button_down(id)
    close if id == Gosu::Button::KbEscape
  end

# private

  def tile_positions
    w, h = @grass.width, @grass.height
    @tile_positions ||= {
      :x => (0...width).to_a.inject([]) {|a,x| a << x if x % w == 0; a},
      :y => (0...height).to_a.inject([]) {|a,y| a << y if y % h == 0; a}
    }
  end

  def map
    @map ||= tile_positions[:y].map do |y|
      tile_positions[:x].map do |x|
        {
          :x => x,
          :y => y,
          :tile => (rand(32) % 32 == 0) ? @shrubbery : @grass
        }
      end
    end
  end

  def draw_scenery
    map.each do |row|
      row.each do |col|
        col[:tile].draw(col[:x], col[:y], ZIndex.for(:world))
      end
    end
  end

  def draw_human
    @human.draw if defined?(@human)
  end

  def draw_zombies
    @zombie_list.draw_zombies if defined?(@zombie_list)
  end

  #No longer a major issue now zombies approach from all directions in GUI mode
  def no_living_zombies_apart_from_me?(desired_step_count, actor)
    true
  end

end
