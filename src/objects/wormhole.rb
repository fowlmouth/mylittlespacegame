module SpaceGame
class Wormhole < PhysicsObject
  def self.anim() @anim ||= Chingu::Animation.new(file: 'wormhole_192x192.png', loop: true) end
  def initialize options={}
    @anim = Wormhole.anim.dup
    @image = @anim.first
    options[:mass] ||= Float::INFINITY
    options[:col_type] ||= :wormhole
    super options
  end
  
  def init_physics #x, y, width, shape, mass
    super #x, y, width, :circle, Float::INFINITY
    @shape.sensor = true
  end
  
  def update
    @image = @anim.next
    super
  end
  
  def draw
    super
    draw_debug
  end
end
end
