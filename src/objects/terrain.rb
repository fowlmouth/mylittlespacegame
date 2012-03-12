module SpaceGame
#describes a poly area on the map that interacts by collision
class Terrain < SpaceGame::PhysicsObject
  def initialize opts = {}, &block
    if opts[:id].nil?
      opts[:id] = :"hihi"
    end

    super({
      col_type: opts[:terrain],
      col_shape: :rect,
      mass: Float::INFINITY,
      }.merge opts)

    @width, @height = opts[:width], opts[:height]

    init_physics
    
    @shape.sensor = true

    @parent.space.add_collision_func(opts[:terrain], :ship, &block) if block

    #binding.pry
  end

  def width()  @width  end
  def height() @height end

  def draw
    super
    draw_debug
  end
  
  DebugColors = [
    Gosu::Color::RED, Gosu::Color::BLUE,
    Gosu::Color::GREEN,Gosu::Color::YELLOW
  ]
  def draw_debug()
    a = @body.a.radians_to_vec2
    @shape.num_verts.times { |v|
      point = @body.pos + @shape.vert(v).rotate(a)
      $window.draw_circle point.x, point.y, 2, DebugColors[v]#::Chingu::DEBUG_COLOR#, 999
    }
  end
end
end
