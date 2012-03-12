
class StaticObject < Chingu::GameObject

  def self.tile id
    tiles[id]
  end
  
  def self.tiles
    @tiles || (
      @tiles = {}
      @tiles[:solid] = [CP::Vec2.new(0,0), CP::Vec2.new(0,1), CP::Vec2.new(1,1), CP::Vec2.new(1,0)]
      @tiles[:nw] = [CP::Vec2.new(0,0), CP::Vec2.new(0,1), CP::Vec2.new(1,0)]
      @tiles[:ne] = [CP::Vec2.new(0,0), CP::Vec2.new(1,1), CP::Vec2.new(1,0)]
      @tiles[:se] = [CP::Vec2.new(1,0), CP::Vec2.new(0,1), CP::Vec2.new(1,1)]
      @tiles[:sw] = [CP::Vec2.new(0,0), CP::Vec2.new(0,1), CP::Vec2.new(1,1)]
      @tiles
    )
  end
  
  def self.tile_img index
    @tile_img ||= Gosu::Image.load_tiles($window, Gosu::Image['Physics_16x16.png'], 16, 16, false)
    @tile_img[tiles.keys.index(index)]
  end
  
  def initialize options={}
    options[:radius] ||= 16
    if options[:tile]
      options[:vectors] ||= StaticObject.tile(options[:tile]).map { |v| v * options[:radius] }
      @image = StaticObject.tile_img(options[:tile])
    end
    options[:factor] ||= 1
    options[:alpha] = 150
    options[:zorder] = 50
    super({rotation_center: :top_left}.merge(options))
    
    return unless options[:vectors]
    return unless CP::Shape::Poly.valid? options[:vectors]
    
    @body = CP::Body.new(Float::INFINITY, Float::INFINITY)
    @body.p = CP::Vec2.new(x, y)
    
    @shape = CP::Shape::Poly.new(@body, options[:vectors], CP::Vec2.new(0,0))
    @shape.e = 0.9
    
    @parent.space.add_body  @body
    @parent.space.add_shape @shape
  end
#=begin
  def x() @body.p.x end
  def y() @body.p.y end
  def pos() @body.p end
#=end
  def draw
    @image.draw_rot x, y, 100, 0, @center_x, @center_y, scale, scale, @color if @image rescue binding.pry
    draw_debug
  end
  
  def draw_debug
    return unless @shape
    @shape.num_verts.times { |v|
      point = @body.pos + @shape.vert(v)
      $window.draw_circle point.x, point.y, 2, ::Chingu::DEBUG_COLOR#, 999
    }
  end
end
