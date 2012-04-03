module SpaceGame
class PhysicsObject < Chingu::BasicGameObject

trait :sprite

  attr_reader :shape, :body
  
  def initialize options={}
    options = {
      x: rand(0..$window.width),
      y: rand(0..$window.height),
      col_type: :blah, 
      col_shape: :circle, 
      mass: 10,
      max_velocity: 35,#10,
      zorder: ZOrder::OBJECTS
    }.merge options
    super options
    #init_physics options[:x], options[:y], options[:radius] ? options[:radius]*2 : width, options[:col_shape], options[:mass]
    init_physics

    @dead = false
  end
  
  def init_physics #x, y, width, shape, mass
    unless @body 
      @body = CP::Body.new(@options[:mass], @options.has_key?(:moment_inertia) ? @options[:moment_inertia] : 150.0)
      @body.p = CP::Vec2.new(@options[:x], @options[:y])
      @body.v_limit = @options[:max_velocity]
      @body.vel = @options[:vel] if @options[:vel]
      @body.vel *= @options[:force] if @options[:force]
    end

    if @options[:col_shape] != :rect || (width && height) # this was to delay generation until the @image exists but im not sure its needed now
      @shape = case @options[:col_shape]
      when :circle
        CP::Shape::Circle.new(@body, @options[:radius] || width/2, CP::Vec2.new(0, 0))
      when :rect
        CP::Shape::Poly.new(@body, CP.recenter_poly([
          vec2(0, 0),          #Top Left Red
          vec2(0, height),     #Btm Left Blue
          vec2(width, height), #Btm Rght Green
          vec2(width, 0),      #Top Rght Yellow
        ]), vec2(0, 0))
      when :poly #unused ATM
        #expect @options[:verts] to be set up
        CP::Shape::Poly.new(@body, CP.recenter_poly(@options[:verts]), vec2(0,0))
      else
        raise "Bad shape #{@options[:col_shape]}, wtf??"
      end
    
      @shape.e = @options[:elasticity] if @options[:elasticity]
      @shape.collision_type = @options[:col_type]
      @shape.object = self

      parent.space.add_body  @body
      parent.space.add_shape @shape
    end
  end


  DebugColors = [
    Gosu::Color::RED, Gosu::Color::BLUE,
    Gosu::Color::GREEN,Gosu::Color::YELLOW,
    Gosu::Color::GRAY,Gosu::Color::FUCHSIA,
    Gosu::Color::WHITE,Gosu::Color::AQUA,
  ]
  def draw_debug()
    if @options[:col_shape] == :circle then
      $window.draw_circle *@body.pos, @shape.radius, ::Chingu::DEBUG_COLOR#, 999  # uncomment for chingu 0.9 
    elsif @options[:col_shape] == :poly || @options[:col_shape] == :rect then
      a = @body.a.radians_to_vec2
      @shape.num_verts.times { |v|
        point = @body.pos + @shape.vert(v).rotate(a)
        $window.draw_circle point.x, point.y, 2, DebugColors[v%8]#::Chingu::DEBUG_COLOR#, 999
      }
    end
  end
  
  def verts()
    @verts ||= ([:poly, :rect].include?(@options[:col_shape]) \
      ? @shape.num_verts.times.map { |i| @shape.vert i }    \
      : nil) #yes this will set to nil every time its ran on a circle, so you shouldn't call it on a circle <3
  end
  
  def dead?() @dead end
  
#   def update
#     super
#     wrap_pos
#   end
  
  def reset_forces() @body.reset_forces(); @body.w *= 0.98 end
  
  #default for non-attachable objects, overwritten by Attachable module
  def has_attached?(o=nil) nil end

  def angle() @body.angle end #@body.vel.to_angle end
  def angle_gosu() angle.radians_to_gosu end
  
  def destroy
    @parent.space.remove_shape @shape
    @parent.space.remove_body  @body
    super
    @dead = true
  end
  
  def hit_by(obj, dmg_factor=1) end
  
  def transparency(percent) self.alpha = (1-percent.f/100.f)*255.f end
  
  def x() @body.p.x end
  def y() @body.p.y end
  def pos() @body.p end
  def warp(x=nil, y=nil, silent=false)
    if x
      if y
        @body.p = CP::Vec2.new(x, y)
      else #assume vec2
        @body.p = x
      end
    else
      @body.p = CP::Vec2.new(rand(@parent.game_area[0]), rand(@parent.game_area[1]))
    end
    return if silent
    anim = Bullet.animation(file: 'warpPorter_128x128.png', delay: 60-(@body.vel.dist(CP::Vec2.new(0, 0))))
    Explosion.create x: @body.p.x, y: @body.p.y, anim: anim, zorder: ZOrder::OBJECTS-1
    @parent.push_sound Gosu::Sound['warpin2.wav'], @body.p
  end
  
  #TODO this needs help, it doesn't wrap correctly, but it works for the moment
  def wrap_pos()
    @body.pos = vec2(       ### @parent.border is the size of the buffer zone
      ((x + @parent.border) % @parent.whole_area[0]) - @parent.border,
      ((y + @parent.border) % @parent.whole_area[1]) - @parent.border)
    #@parent.whole_area[0 and 1] are game_area[x and y] + (buffer_zone * 2)
    #the game area + 2x buffer so the position doesnt get fucked up
    #
    #old:
    #@body.pos = vec2((x % @parent.game_area[0]), (y % @parent.game_area[1]))
  end
end
end
