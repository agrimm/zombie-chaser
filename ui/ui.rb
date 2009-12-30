#Fixme: only require gosu if it's going to be used?
begin
  require 'gosu'
rescue LoadError => e
  puts "gosu gem not available! Using fake implementations of Gosu."
  require 'ostruct'
  module Gosu
    class Window
      attr_accessor :caption, :grid
      def initialize(one, two, three)
      end
    end
    
    class Image
      def initialize(*args)
      end
    end
  end
end

class ZIndex
  LAYERS = [:world, :dead, :human, :zombie, :overlay]

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
    image.draw_rot(x, y, z, actor_direction)
  end

  def x
    max_position = Window.width - 10
    left_offset = 10
    left_offset + ((@successful_step_count * 10) * (max_position - left_offset) / [test_suite_size * 10 + 10, (max_position - left_offset)].max).round
  end

  def y
    100
  end

  def z
    #(data['state'] == 'dead') ? ZIndex.for(:dead) : ZIndex.for(data['type'].to_sym)
    ZIndex.for(:human)
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
  attr_writer :human, :current_zombie

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
    draw_zombie
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
    @human.draw
  end

  def draw_zombie
    @current_zombie.draw if defined?(@current_zombie)
  end

end
