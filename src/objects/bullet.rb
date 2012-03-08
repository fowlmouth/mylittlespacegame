module SpaceGame
class Bullet < PhysicsObject
trait :timer
  class << self
    def [] key=nil, fireopts = nil
      @bullets ||= YAML.load_file('data/bullets.yml')
      if @bullets.has_key?(key)
        @bullets[key]
      else
        raise "invalid bullet #{key}"
      end
    end
    
    def animation opts = {}
      @animations ||= {}
      file = opts.is_a?(String) ? opts : opts[:file]
      if @animations[file]
        file = @animations[file].dup.reset
        file.delay = opts[:delay]
        file
      else
        @animations[file] = Chingu::Animation.new(file: file) if opts.is_a? String
        @animations[file] = Chingu::Animation.new(opts)
      end
    end

    def animation_frames key, frames = 0..-1
      animation(key)[frames]
    end
  end
  
  Events = {
    asteroid_hook: lambda do |obj, bullet|
      bullet.from.grapple(obj) \
        if obj.is_a?(Asteroid) \
        || obj.is_a?(Resource)        end,
    repel: lambda do |obj, bullet|
      #placeholder
      #completely wrong
      obj.body.apply_impulse \
        vec2(10, 0), # ang between
          #the bullet and the ship
          #      + some force/dist
        vec2( 0, 0)            end
  }
  
  attr_reader :damage, :from
  
  def initialize options={}
    options[:elasticity] ||= 1
    #binding.pry
    if options[:bullet][:rot_points]
      @anim = Animation64degree[options[:bullet][:img]]
      @rot_points = options[:bullet][:rot_points]
      @image = @anim[0]
    else
      @anim = Bullet.animation \
        file: options[:bullet][:img],
        size: options[:bullet][:size],
        delay: options[:bullet][:delay] || 50,
        loop: true
      @anim.reset
      @image = @anim.first
    end
    
    super({
      mass: options[:bullet][:mass] || 3,
      radius: options[:bullet][:radius] || nil,
      col_type: :bullet,
      zorder: ZOrder::BULLETS
    }.merge(options))
    
    @body.pos = options[:pos]
    @from = options[:from]
    
    if options[:bullet][:absolute_velocity]
      @body.vel = options[:from].body.angle.radians_to_vec2 * options[:bullet][:absolute_velocity]
    else
      @body.vel = options[:from].body.vel + (options[:from].body.angle.radians_to_vec2 * options[:bullet][:speed])
    end
    
    if options[:bullet][:special]
      if te = options[:bullet][:special][:trigger_event]
        @trigger_event = Bullet::Events[te]
      end
    end
    
    if options[:bullet][:trail]
      options[:bullet][:trail][:anim] ||= if options[:bullet][:trail][:range] then
        options[:bullet][:trail][:range] = eval(options[:bullet][:trail][:range]) if options[:bullet][:trail][:range].is_a?String
        Bullet.animation_frames(options[:bullet][:trail], options[:bullet][:trail][:range])
      else Bullet.animation(options[:bullet][:trail]) end

      options[:bullet][:trail][:timer] ||= 20
      #binding.pry
      #this needs replacing, it should fire one off by distance
      #but i cant think of an efficient way to do that
      after(25) {
      every(options[:bullet][:trail][:timer]) {
        Explosion.create x: x, y: y,
          angle: @body.vel.to_angle.radians_to_gosu,
          anim: options[:bullet][:trail][:anim],
          color: options[:bullet][:trail][:color],
          zorder: ZOrder::TRAILS
      }
      }
    end
    
    if options[:bullet][:color]
      options[:bullet][:color] = Gosu::Color.const_get(options[:bullet][:color]) if options[:bullet][:color].is_a?Symbol
      self.color = options[:bullet][:color]
    end
    
    if options[:bullet][:explode]
      options[:bullet][:explode][:anim] ||= Bullet.animation(file: options[:bullet][:explode][:image], delay: options[:bullet][:explode][:delay]) \
        if options[:bullet][:explode][:image]
    end
    
    @damage = options[:bullet][:damage]
    
    if options[:bullet][:prox]
      after options[:bullet][:prox][:delay] do
        @shape.set_radius! @prox = options[:bullet][:prox][:radius]
        @shape.sensor = true
        @triggered = false
      end
    end
    
    if options[:bullet][:rotation]
      after options[:bullet][:rotation][:delay] do
        every options[:bullet][:rotation][:timer], during: options[:bullet][:rotation][:during] do
          #puts "Turning! #{options[:bullet][:rotation][:turn]}"
          #turn options[:bullet][:rotation][:turn]
          @body.vel = @body.vel.rotate(options[:bullet][:rotation][:turn].degrees_to_radians.radians_to_vec2)
        end
      end
    end
    
    after(options[:bullet][:timer] || 3000) { explode }
  end
  
  def trigger(obj)
    return false if obj == @from
    if @prox
      unless @triggered
        @triggered = [obj, pos.dist(obj.pos)]
      else
        if @triggered[0] == obj
          dist = pos.dist(obj.pos)
          if dist > @triggered[1]
            # maybe here apply impulse to the obj ?
            # do later
            obj.hit_by(self, (@prox-dist)/@prox) #damage factor from edge of prox (0) to mid point (1)
            @trigger_event.(obj, self) if @trigger_event
            explode
          else
            @triggered[1] = dist
          end
        end
      end
      false
    else
      obj.hit_by(self)
      @trigger_event.(obj, self) if @trigger_event
      explode
      true
    end
  end
  
  def init_physics
    super
    @body.velocity_func do |body, gravity, damping, dt|
      body.update_velocity(gravity, 1.0, dt)
    end
    @shape.e = 0.7
  end
  
  def explode
    #p @options[:bullet]
    if @options[:bullet][:explode]
      #p @options[:bullet][:anim]
      Explosion.create(x: x, y: y, angle: @body.vel.to_angle.radians_to_gosu, anim: @options[:bullet][:explode][:anim]) if @options[:bullet][:explode][:anim]
      $window.current.push_sound(Gosu::Sound[@options[:bullet][:explode][:sound]], pos) if @options[:bullet][:explode][:sound]
    end
    
    destroy
  end
  
  def angle() @body.vel.to_angle end
  
  def update
    if @rot_points
      @image = @anim[(angle_gosu/360.0*@rot_points).to_i]
    elsif @anim
     # p @anim
      #binding.pry
      @image = @anim.next if @anim
    end
  end
  
  
  def draw
    #super
    #p @body.angle.radians_to_gosu
    if @rot_points
      @anim[(angle_gosu/360.0*@rot_points).to_i].draw_rot x, y, 100, 0, @center_x, @center_y, @factor_x, @factor_y
    elsif @anim
      @anim.next.draw_rot x, y, 100, angle_gosu.i, @center_x, @center_y, @factor_x, @factor_y
    end
    #$window.draw_circle *@body.pos, @shape.radius, ::Chingu::DEBUG_COLOR, 999
  end
end
end
