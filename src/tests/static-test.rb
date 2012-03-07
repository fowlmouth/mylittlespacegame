module SpaceGame
module Tests
class StaticTest < PhysicsState
  include DebugGUI
  def setup
    game_area 1400, 960
    
    @cursor = Cursor.create(image: 'arrow.png', rotation_center: :top_left)
    def @cursor.update
      @x, @y = $window.mouse_x - $window.mouse_x%16, $window.mouse_y - $window.mouse_y%16
    end
    #@cursor = Cursor.create image: 'starA5_0000.png', zorder: 800
    
    @tiles = [:solid, :nw, :ne, :se, :sw]
    @points, @ind = [], 0
    @preview = Chingu::GameObject.create(x: SCREEN_SIZE[0]/2, y: SCREEN_SIZE[1]-40)
    switch_tile 0
    
    keys_info '[ESC] Quit game'
    keys_info '[P] Start pry'
    keys_info '[A] Add new asteroid'
    keys_info '[LCLICK] New point on poly'
    keys_info ''
    keys_info '[J/K] Switch active obj'
    keys_info '[RCLICK] Place object'
      
    self.input = {
      escape: :exit,
      p: -> { binding.pry },
      a: -> { 
        
      },
      #holding_mouse_left: :lclick,
      #holding_mouse_right: :rclick,
      mouse_left: -> {
        @points << CP::Vec2.new(@cursor.x, @cursor.y)
      },
      mouse_right: -> {
        StaticObject.create \
          tile: @tiles[@ind],
          x: @cursor.x, 
          y: @cursor.y
      },
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
end
end
end
