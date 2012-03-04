
module SpaceGame
#explosions just animate once and die
class Explosion < Chingu::BasicGameObject
trait :sprite
  #these are just random explosions I'll sort them out later but for now they're used for asteroids
  TYPES = [
    ['explosions/deathExplosion1_72x72.png'],
    ['explosions/deathExplosion2_88x88.png'],
    ['explosions/deathExplosion3_88x88.png'],
    ['explosions/deathExplosion4_88x88.png'],
    ['explosions/deathExplosion5_88x88.png']]
  def self.random_explosion(x, y)
    e = rand(TYPES.size)
    #binding.pry
    TYPES[e][1] ||= Chingu::Animation.new(file: TYPES[e][0], delay: 5)
    Explosion.create(x: x, y: y, anim: TYPES[e][1])
  end
  
  def initialize opts={}
    #until all the animations are cached in one place you have to send the anim object here
    @anim = opts[:anim].clone or raise 'Invalid or missing animation' 
    @anim.reset
    @image = @anim.first
    if opts[:pos]
      opts[:x], opts[:y] = *opts[:pos]
    end
    opts[:zorder] ||= ZOrder::EXPLOSIONS
    @min_zorder = opts[:zorder] - 15
    if opts[:color] && opts[:color].is_a?(Symbol)
      opts[:color] = Gosu::Color.const_get(opts[:color])
    end
    super opts
    #binding.pry
  end
  
  def update
    super
    @zorder -= 1 unless @zorder == @min_zorder
    if @anim
      @image = @anim.next
      destroy if @anim.index == @anim.frames.size-1
    end
  end
end
end
