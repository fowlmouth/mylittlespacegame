module SpaceGame
module Tests
#not surprisingly, this doesnt work as intended :<
class HyperTunnelTest < SpaceGame::PhysicsState
  def setup
    game_area $window.width * 10, $window.height
    
    r = 700
    x, y = 100, 250
    spacing = 300
    20.times { |_|
      Wormhole.create x: x + (_ * spacing), y: y, radius: r
    }
    x, y = 100, game_area[1]-250
    20.times { |_|
      Wormhole.create x: x + (_ * spacing), y: y, radius: r
    }
    
    @player = PlayerShip.create ship: :Masta
    
    super
    
    self.input = { 
      escape: :dat_menu,
      i: -> { @player.warp 500, 500 }
      }
    
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
    @space.add_collision_func(:wormhole, :wormhole, &nil)
  end
end

end
end
