module SpaceGame
module Tests
class StaticTest < PhysicsState
  include DebugGUI
  def setup
    game_area $window.width, $window.height
    border 10, no_collide: [:ship]
    super
    
    @cursor = DebugCursor.create(image: 'arrow.png', rotation_center: :top_left)
    
    @tiles = [:solid, :nw, :ne, :se, :sw]
    @points, @ind = [], 0
    @preview = Chingu::GameObject.create \
      x: game_area[0]/2, y: game_area[1]-40
    switch_tile 0
    
    @validtxt = Chingu::Text.create '', size: 20, x: 100, y: 5, rotation_center: :top_left
    @can_destroy = true
    
    keys_info '[ESC] Quit game'
    keys_info '[P] Start pry'
    #keys_info '[A] Add new asteroid'
    keys_info ''
    keys_info '[LCLICK] New point on poly'
    keys_info '[RCLICK] Clear last point'
    keys_info '[MCLICK] Clear all points'
    keys_info '[SPACE] Accept Poly'
    keys_info '[M] Destroy last Poly'
    keys_info ''
    keys_info '[J/K] Switch active obj'
    keys_info '[RCLICK] place static obj'
      
    self.input = {
      escape: :dat_menu,
      p: -> { binding.pry },
      a: -> { 
        
      },
      #holding_mouse_left: :lclick,
      #holding_mouse_right: :rclick,
      mouse_left: :lclick,
      mouse_right: -> {
        unless @points.empty? then @points.pop; points_are_valid?(true)
        else StaticObject.create \
          tile: @tiles[@ind],
          x: @cursor.x, 
          y: @cursor.y end
      },
      mouse_middle: -> { @points = []; @validtxt && @validtxt.text='' },
      m: -> {
        return unless @can_destroy
        @can_destroy = false
        after(500) do @can_destroy = true end
        (o = game_objects_of_class(PolyObject)[-1]) \
        && o.destroy
      },
      space: :accept_poly,
      j: -> {
        switch_tile(-1)
      },
      k: -> {
        switch_tile(1)
      },
    } 
    StaticObject.create tile: :nw, x: 0, y: 0
    StaticObject.create tile: :ne, x: game_area[0]-32, y: 0
    StaticObject.create tile: :se, x: game_area[0]-32, y: game_area[1]-32
    StaticObject.create tile: :sw, x: 0, y: game_area[1]-32
    
    Terrain.create id: :t1, x: 16*4, y: 16*8, width: 16*3, height: 16
    
    @player = PlayerShip.create ship: :Masta, unlimited_energy: true
=begin    
#scrapped idea, creates way too many objects
    character_map = {
      ?#  => :solid,
      ' ' => nil,
      ?/  => :nw,
      ?\  => :ne,
    }
    (File.readlines File.expand_path './src/map.txt').each_with_index { |line, y|
      line.split('').each_with_index { |chr, x|
        tile = character_map.has_key?(chr) ? character_map[chr] : nil
        if tile
          #StaticObject.create tile: tile, x: x*16, y: y*16
          StaticObject.create tile(tile), x: x*16, y: y*16
        end
      }
    }
=end
    
  end
  
  def switch_tile offs=1
    @ind = (@ind+offs)%@tiles.size
    @preview.image = StaticObject.tile_img @tiles[@ind]
  end

  def lclick
    #record clicks as points for a poly
    #TODO some warning message about the order of verts expected (counter clockwise)
    #saves points as [ 
    # Vec2 cursor pos,
    # Vec2 difference from point0
    #]
    @points << (
      [ p = vec2(@cursor.x, @cursor.y) ] << 
      (p - (@points.empty? ? p : @points[0][0]))
    )
    points_are_valid?(true) if @points.size > 2
  end
  
  def accept_poly
    #create a poly according to @points
    return unless points_are_valid?
    x, y = *@points[0][0]
    po = PolyObject.create x: x, y: y, verts: verts
    @points = []
    @validtxt && @validtxt.text = ''
  end
  
  class PolyObject < PhysicsObject
    def initialize(opts = {})
      super opts.merge(col_type: :blah, col_shape: :poly, angle: 180)
    end
    
    def draw() super;draw_debug end
  end

  def verts
    @points.map{|p| p[1]}
  end

  def points_are_valid? update_graphic = false
    res = @points.size < 3 ? false : CP::Shape::Poly.valid?(verts)
    if update_graphic && @validtxt
      if res then @validtxt.text = 'Dat poly\'s valid, son'
      else @validtxt.text = 'It\'s no good bro' end
    end
    res
  end

  def draw
    super
    @points.each_with_index do |p, i|
      $window.draw_circle p[0].x, p[0].y, 2, PhysicsObject::DebugColors[i % 8]
    end
  end
end
end
end
