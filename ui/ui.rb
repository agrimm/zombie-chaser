require 'gosu'

class ZIndex
  LAYERS = [:world, :dead, :human, :zombie, :overlay]

  def self.for(type); LAYERS.index(type) end
end

class Actor

  def self.window=(window); @window = window end
  def self.window; @window end

  def self.sprites
    @sprites ||=  Dir['ui/sprites/*.png'].inject({}) do |sprites,f|
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
    @successful_step_count * 10 + 10
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

  attr_accessor :grid
  attr_writer :human, :current_zombie

  def initialize
    super(400, 300, false)

    self.caption = 'Zombie-chaser'
    self.grid = 1

    @grass     = Gosu::Image.new(self, 'ui/tiles/grass.png', true)
    @shrubbery = Gosu::Image.new(self, 'ui/tiles/shrubbery.png', true)
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
