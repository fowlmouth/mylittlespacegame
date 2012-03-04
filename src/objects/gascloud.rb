module SpaceGame
class GasCloud < PhysicsObject
  
  TYPES = [
    ['gascloud/gasCloudA_128x128.png'],
    ['gascloud/gasCloudB_128x128.png'],
    ['gascloud/gasCloudC_128x128.png'],
    ['gascloud/gasCloudA_96x96.png'],
    ['gascloud/gasCloudB_96x96.png'],
  ]
  
  def self.[] key
    @animations ||= {}
    return @animations[key].dup if @animations.has_key? key
    @animations[key] = Chingu::Animation.new(file: key, loop: true)
  end
  
  def initialize options={}
    cloud = TYPES.sample
    options = {
      col_type: :cloud,
      col_shape: :circle,
      mass: 10,
    }.merge options
    
    @anim = GasCloud[cloud[0]]
    @image = @anim.first
    @anim.delay = Gosu.random(30, 420).i
    @anim.reset
    
    super options
    
  end
  
  def init_physics *args
    super *args
    @body.velocity_func do |body, gravity, damping, dt|
      body.update_velocity(gravity, 0.99, dt)
    end
    @shape.sensor = true
    @body.angle = rand(360).gosu_to_radians
  end
  
  def draw
    (@anim.next).draw_rot x, y, 100, angle_gosu, @center_x, @center_y, 1, 1, @color
    $window.draw_circle *@body.pos, @shape.radius, ::Chingu::DEBUG_COLOR, 999
    #$window.draw_rect [@body.pos.x, @body.pos.y, @body.pos.x+1, @body.pos.y+1], ::Gosu::Color::GREEN, 1000
  end
end
end
