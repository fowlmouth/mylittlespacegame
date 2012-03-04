module SpaceGame
class Asteroid < PhysicsObject
  
  TYPES = [
    # image,                     radius,mass, elas.,health,scale
    #   explosion objects created [ [id, number], ... ]
    
    #0
    ['asteroids/Rock64a_64x64.png', 27,   70,  0.91,  30,    1,
     [[3, 1], [7, 2], [8, 1]]],
    #1
    ['asteroids/Rock64b_64x64.png', 27,   70,  0.91,  30,    1,
     [[5, 1], [6, 2], [10, 1]]],
    #2
    ['asteroids/Rock64c_64x64.png', 27,   70,  0.91,  30,    1,
     [[4, 1], [8, 2], [10, 2]]],
    #3
    ['asteroids/Rock48a_48x48.png', 22,   38,  0.95,  25,    1,
     [[7, 2], [10, 2]]],
    #4
    ['asteroids/Rock48b_48x48.png', 21,   38,  0.95,  25,    1,
     [[6, 2], [9, 1]]],
    #5
    ['asteroids/Rock48c_48x48.png', 22,   38,  0.95,  25,    1,
     [[7, 1], [8, 1]]],
    #6
    ['asteroids/Rock32a_32x32.png', 12,   12,  0.94,  15,    1,
     [[10, 1]]],
    #7
    ['asteroids/Rock24a_24x24.png', 11,    9, 0.925,   9,    1,
     [[10, 1]] ],
    #8
    ['asteroids/Rock24b_24x24.png', 11,    9, 0.925,   9,    1,
     [[Iron, 1]] ],
    #9
    ['asteroids/Meteor_32x32.png',  11,    4,  0.91,   4,    1,
     [] ],
    #10
    ['asteroids/Rock24b_24x24.png',  7,    1, 0.925,   3,  0.5,
     [] ],
  ]
  
  def self.[] key=nil
    @animations ||= {}
    @animations[key] ? @animations[key].clone : @animations[key] = Chingu::Animation.new(file: key, loop: true)
  end
  
  attr_reader :health
  include PhysicsObject::Attachable
  
  def initialize options={}
    ast = options[:ast] ? TYPES[options[:ast]] : TYPES.sample
    options = {
      col_type: :asteroid,
      col_shape: :circle,
      mass: ast[2],
      radius: ast[1],
      elasticity: ast[3],
      scale: ast[5],
    }.merge options
    
    @anim = Asteroid[ast[0]]
    @image = @anim.first
    @anim.delay = Gosu.random(230, 500)
    @anim.reset

    @springs = []
    
    super options
    
    @health = @max_health = ast[4].f
    
    if ast[-1].is_a? Array
      @explosion_fire = ast[-1]
    end
    
    puts "#{Asteroid.all.size} Asteroids" if false
  end
  
  def future_pos() @body.pos + (@body.vel * 3) end
  def radius() @shape.radius end

  # def add_spring(spring, ship)
  #   @springs << [spring, ship]
  # end
  
  def init_physics
    super
    #binding.pry
    @body.velocity_func do |body, gravity, damping, dt|
      body.update_velocity(gravity, 1.0, dt)
    end
    
    if !@options[:moving] || @options[:moving] == false
      @body.vel = rand(360).degrees_to_radians.radians_to_vec2 * rand(3..5)
    #elsif @options[:vel]  ## moved to physicsobject
    #  @body.vel = @options[:vel]
    end
    @body.vel *= @options[:force] if @options[:force]
  end
  
  def draw
    (@anim.next).draw_rot x, y, 100, 0, @center_x, @center_y
    #$window.draw_circle *@body.pos, @shape.radius, ::Chingu::DEBUG_COLOR, 999
    # r = @health/@max_health
    #r < 0 ?
    #  explode :
    #  $window.fill_rect([x-radius, y+radius, 30*r, 3], 0xff000000 + (0xff*r).to_i*256 + (0xff*(1-r)).to_i*256*256, 2)

    #$window.draw_rect [@body.pos.x, @body.pos.y, @body.pos.x+1, @body.pos.y+1], ::Gosu::Color::GREEN, 1000
  end
  
  def explode
    Explosion.random_explosion(x, y)
    @explosion_fire.each { |ast|
      ast[0].is_a?(Fixnum) ?
        ast[1].times { Asteroid.create(x: x, y: y, ast: ast[0], force: Gosu.random(2,4)+(rand(10)*0.1)) } :
        ast[1].times { ast[0].create(x: x, y: y) }
    } if @explosion_fire
    @parent.push_sound ::Gosu::Sound[%w(explode1.wav explode02.wav).sample], pos
    destroy
  end
  
  def hit_by obj, dmg_factor = 1
    #in most cases will be a bullet
    return unless obj.damage
    @health -= (obj.damage[:asteroid] || obj.damage[:health]) * dmg_factor unless @options[:invincible]
    explode if @health < 0
  end
end
end
