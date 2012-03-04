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
    @game_area = [1400, 960]
    @cursor = Cursor.create #image: 'star5A_0000.png', zorder: 800
    wormh = Wormhole.create x: @game_area[0]/2, y: @game_area[1]/2, radius: 400
    #@ast = Asteroid.create x: 500, y: 500
    @player = PlayerShip.create ship: :Zag
    #[:cannonA, :nbomb, :moltor_rocks].each { |w| @player.equip w }
      
    keys_info '[ESC] Quit game'
    keys_info '[P] Start pry'
    keys_info '[T] Target new asteroid'
    keys_info '[A] Add new asteroid'
      
    self.input = {
      escape: :exit,
      p: -> { binding.pry },
      t: -> { @player.find_new_target },
      a: -> { 
        ast = ASTEROID_VECTORS.sample
        Asteroid.create x: ast[0], y: ast[1], vel: ast[2], force: 2
      },
      #holding_mouse_left: :lclick,
      #holding_mouse_right: :rclick,
      mouse_left: -> {
        if ast = closest_asteroid then
          ast.explode
        end
      },
      mouse_right: -> { Asteroid.create x: @cursor.x, y: @cursor.y },
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
    @space.add_collision_func(:EnemyBullet, :wormhole, &p)
    @space.add_collision_func(:PlayerBullet, :wormhole, &p)
    
    super
  end
  
  def closest_asteroid()
    Asteroid.all.sort_by { |a|
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
