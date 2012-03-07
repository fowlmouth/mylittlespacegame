module SpaceGame
class ChooseGame < PhysicsState
	GameStates = {
		'Test Zone #1'  => [SpaceGame::TestZone1, 48], #size 24, factor 2
		'Turret Test'   => [SpaceGame::Tests::TurretTest, 24],
		'Wormhole Test' => [SpaceGame::Tests::WormholeTest, 36],
		'Static Test'   => [SpaceGame::Tests::StaticTest, 36],
#		'Thrust Test' => SpaceGame::Tests::ThrustTest, #not useful
		'Asteroid test' => [SpaceGame::Tests::AsteroidTest, 36],
		'Ship Test'     => [SpaceGame::Tests::ShipTest, 36],
		'GrapplingTest' => [SpaceGame::Tests::GrapplingTest, 40],
	}
  include Tests::DebugGUI
  attr_reader :ready
	def setup
		game_area $window.width, $window.height
    border 50, no_collide: [:asteroid, ]#:bullet]
    
    opts = {
      col_type: :text,
      col_shape: :rect,
      mass: 15,
      elasticity: 0.95,
      force: 0#0.92
    }
		GameStates.each { |name, state| 
			FloatyText.create name, 
        state[0], state[1], 
        opts.merge(
          factor: state[2] || 1, 
          mass: opts[:mass]*(state[1]/48.0)
        )
		}
    #forgot what i was going to put in here so disabled before i
    #even start on it
    StaticText.create('Settings',
      color: ::Gosu::Color::GREEN,
      size: 24) do
        StaticText.create('Settings screen not done yet',
          x: 100, y: 100, size: 36, expire: 2500)
        #goto_state(SpaceGame::ConfigState)
    end
    
    #15.times { Asteroid.create x: rand_x, y: rand_y, force: 1.3 }
    #Asteroid.create x: rand_x, y: rand_y, force: 2
    
    @player = PlayerShip.create ship: :Masta, weapons: [:grapple_hook]
    
    self.input = {
      esc: :exit,
      p: proc do binding.pry end,
      a: proc do Asteroid.create force: 2.3 end,
      mouse_left:  :lclick,
      mouse_right: :rclick
    }
    @cursor = Cursor.create factor: 2
    @space.damping = 0.98
    super
    
    @space.add_collision_func(:bullet, :text) do |b, t| b.object.trigger t.object end
    
    @ready = true
	end
  
  def goto_state(state, name)
    @ready = false
    StaticText.create name, size: 50,
      x: game_area[0]/2, y: game_area[1]/2,
      rotation_center: :center, expire: 500
    after(200) { $window.push_game_state state }
  end
  
  def finalize()
    @ready = true
  end

  def update()
    super
    $window.caption = "Cursor @ #{@cursor.x}/#{@cursor.y} | Player @ #{@player.x},#{@player.y}"

  end
  def lclick
    # x,y = @cursor.x - (5 * 16), @cursor.y
    # 10.times { |z|
    #   Pixel.create x: x, y: y
    #   x += 16
    # }

    StaticText.each_at @cursor.x, @cursor.y do |text|
      text.on_click.call
    end
  end
  def rclick
    x,y = @cursor.x, @cursor.y - (5 * 16)
    10.times { |z|
      Pixel.create x: x, y: y
      y += 16
    }
  end
  
class Pixel < PhysicsObject
  class << self
    def animation()
      @animation ||= Chingu::Animation.new(file: 'bullets/EbulletB_12x12.png')
    end
  end
  
  def initialize(opts={})
    super({ col_type: :trash, col_shape: :circle, radius: 3, mass: 0.01 }.merge opts)
    @anim = Pixel.animation.dup rescue binding.pry
  end

  def draw() (@anim.next).draw_rot(x, y, 100, 0, @center_x, @center_y) end
end
class FloatyText < PhysicsObject
	def initialize(name, state, size = 36, opts = {})
    @name, @state = name, state
    
    @image = Gosu::Image.from_text $window, name, "#{ROOT_DIR}/data/fnt/pricedown.ttf", size#, #0, 250, :left
    opts[:x] ||= $window.current_scope.rand_x #rescue binding.pry
    opts[:y] ||= $window.current_scope.rand_y
    opts[:rotation_center] = :center
		super opts
    
    @body.vel = rand(360).degrees_to_radians.radians_to_vec2 * rand(3..5)
    @body.vel *= opts[:force] if opts[:force]
    @body.angle = 0.gosu_to_radians
	end

  def to_s() "#{@name.downcase} => #{"#@state".downcase} -- " << super end
  
  def draw()
    @image.draw_rot x, y, @zorder, @body.a.radians_to_gosu % 360, @center_x, @center_y, @factor_x, @factor_y, @color, @mode
    draw_debug
  end

  def hit_by obj, *_
    #binding.pry
    @parent.goto_state @state, @name \
      if obj.is_a?(Bullet) && obj.from.is_a?(PlayerShip) \
                 && @state && @parent.ready
  end
end
class StaticText < Chingu::Text
  trait :collision_detection
  trait :bounding_box#, debug: true
  trait :timer
  def initialize text = '', opts={}, &block
    super text, opts
    @on_click = block
    after(opts[:expire]) do destroy end if opts[:expire]
  end
  attr_reader :on_click
end
end
end
