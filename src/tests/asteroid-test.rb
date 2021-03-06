module SpaceGame
module Tests
class AsteroidTest < PhysicsState
# Thsi test is pretty useless ATM but I coul always use it later
include DebugGUI

def setup
  game_area $window.width, $window.height
  
  @c = Cursor.create
  @player = PlayerShip.create ship: :Masta #, weapons: [:mass_driver]
  @player.warp 500, 500
  
  keys_info '[1] 64x64'
  keys_info '[2] 48x48'
  keys_info '[3] 32x32'
  keys_info '[4] 24x24'
  
  self.input = {
    :escape => :dat_menu,
    :'1' => -> { ast(0..2) },
    :'2' => -> { ast(3..5) },
    :'3' => -> { ast(6..8) },
    :'4' => -> { ast(9..10) }
  }
end

def ast(r)
  r.each { |a|
    Asteroid.create(ast: a, pos: @c.pos)
  }
end


end; end; end
