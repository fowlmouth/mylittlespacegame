module SpaceGame
module Tests
class WormholeTest < PhysicsState
  include DebugGUI
  ASTEROID_VECTORS = [
    [200, 200, CP::Vec2.new(0, 1)],
    [200, 760, CP::Vec2.new(0, -1)],
    [1200, 760, CP::Vec2.new(-1, 0)],
    [1200, 200, CP::Vec2.new(1, 0)]
  ]
  def setup
    game_area $window.width, $window.height
    @cursor = Cursor.create #image: 'star5A_0000.png', zorder: 800
    wormh = Wormhole.create x: @game_area[0]/2, y: @game_area[1]/2, radius: 400
    #@ast = Asteroid.create x: 500, y: 500
    @player = PlayerShip.create ship: :Zag
    #[:cannonA, :nbomb, :moltor_rocks].each { |w| @player.equip w }
      
    keys_info '[ESC] Return to menu'
    keys_info '[P] Start pry'
    keys_info '[T] Target new asteroid'
    keys_info '[I] Add new asteroid'
    keys_info '[Y] Asteroid Velocity Limit +5'
    keys_info '[H] Asteroid Velocity Limit -5'

    @can_raise_vel = true
    self.velocity_limit = 50.0
    add_debug_info 'Asteroid vel limit' do "#@velocity_limit" end
      
    self.input = {
      escape: :dat_menu,
      p: -> { binding.pry },
      t: -> { @player.find_new_target },
      i: -> { 
        ast = ASTEROID_VECTORS.sample
        (Asteroid.create x: ast[0], y: ast[1], vel: ast[2], force: 40).body.v_limit = @velocity_limit
      },
      #holding_mouse_left: :lclick,
      #holding_mouse_right: :rclick,
      mouse_left: -> {
        if ast = closest_asteroid then
          ast.explode
        end
      },
      mouse_right: -> {
        (Asteroid.create x: @cursor.x, y: @cursor.y).body.v_limit = @velocity_limit 
      },
      y: :raise_vel,
      h: :lower_vel,
    } 
    
    add_debug_info 'Collision data' do
      "#{wormh.pos.distsq(@player.pos)}"
    end
    
    p = proc { |ast, wh|
      x = Math.atan2(wh.body.pos.y - ast.body.pos.y, wh.body.pos.x - ast.body.pos.x)
      #x = Math.atan2(wh.body.pos.x - ast.body.pos.x, wh.body.pos.y - ast.body.pos.y)
      #p x.radians_to_vec2*1_000/(ast.body.pos.distsq(wh.body.pos))#/2.0
      
      ast.body.apply_impulse x.radians_to_vec2*10_000/(ast.body.pos.distsq(wh.body.pos)), CP::Vec2.new(0,0)
      
      ast.object.warp if ast.body.pos.dist(wh.body.pos) < 40
      #binding.pry
      true
    }
    
    @space.add_collision_func(:asteroid, :wormhole, &p)
    @space.add_collision_func(:ship, :wormhole, &p)
    @space.add_collision_func(:bullet, :wormhole, &p)
    
    super
  end

  def raise_vel(by=5)
    @can_raise_vel = false
    self.velocity_limit = @velocity_limit + by
    after(200) do @can_raise_vel = true end
  end
  def lower_vel(by=5) raise_vel(-by) end
  def velocity_limit=(v)
    @velocity_limit = v
    game_objects_of_class(Asteroid).each { |a| a.body.v_limit = v }
  end
  
  def closest_asteroid()
    game_objects_of_class(Asteroid).sort_by { |a|
      a.pos.distsq(@cursor.pos)
    }.first or nil
  end
  
  def draw
    super
    if ast = closest_asteroid 
      ast.draw_debug
    end
  end

end
end
end
