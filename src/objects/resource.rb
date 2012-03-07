module SpaceGame
class Resource < PhysicsObject
include PhysicsObject::Attachable
  def self.[] key, opts={}
    @animations ||= {}
    if @animations[key]
      anim = @animations[key].dup
      anim.reset
      opts.each { |key, value| anim.send "#{key}=", value }
      anim
    else
      @animations[key] = Chingu::Animation.new({file: key}.merge(opts))
    end
  end
  
  attr_reader :weight

  def init_physics
    super
    @shape.collision_type = :resource
  end
  
  def weight= v
    @weight = @body.mass = v
  end
  
  def draw
    (@anim.next).draw_rot x, y, 100, 0, 0.5, 0.5
  end
  
  def future_pos()
    pos
  end
  
  def health() false end
end

class Iron < Resource
  def initialize opts={}
    @anim = Resource['resources/IronOre_32x32.png', delay: Gosu.random(30, 90)]
    @image = @anim.first
    
    super opts
    
    self.weight = 3
  end
end

class MineralA < Resource
  def initialize opts={}
    @anim = Resource['resources/ResourceA_26x26.png', delay: Gosu.random(30,120)]
    @image = @anim.first
    
    super opts
    
    self.weight = 1
  end
end

class MineralB < Resource
  def initialize opts={}
    @anim = Resource['resources/ResourceB_26x26.png', delay: Gosu.random(30,50)]
    @image = @anim.first
    
    super opts
    
    self.weight = 4
  end
end

#Debris is a single piece of wreckage
#Debris.HappySetExplosion() creates a bunch of debris for an explosion
class Debris < Resource
  DebrisSets = [
    [ 'debris/ChunkA_24x24.png',
      'debris/ChunkB_24x24.png',
      'debris/ChunkC_24x24.png',
      'debris/ChunkD_24x24.png',
      'debris/ChunkE_24x24.png',
      'debris/ChunkF_24x24.png',
    ], [
      'debris/ChunkG_24x24.png',
      'debris/ChunkH_24x24.png',
      'debris/ChunkI_24x24.png',
      'debris/ChunkJ_24x24.png',
    ]
  ]
  def self.HappySetExplosion(s, x, y, force, num = 4)
    num.times do
      Debris.create \
        debris: DebrisSets[s].sample,
        x: x, y: y, 
        vel: rand(360).degrees_to_radians.radians_to_vec2,
        force: rand(force)
    end
  end
  def initialize opts={}
    opts[:debris] ||= DebrisSets[0].sample
    @anim = Resource[opts[:debris], delay: rand(30..50)]
    @image = @anim.first

    super opts

    self.weight = 0.2

    @body.velocity_func do |body, gravity, damping, dt|
      body.update_velocity(gravity, 0.989, dt)
    end
  end
end
end
