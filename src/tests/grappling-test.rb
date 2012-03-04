module SpaceGame
module Tests
class GrapplingTest < PhysicsState

include DebugGUI


  def setup
    game_area 1400, 960
    @cursor = Cursor.create image: 'star5A_0000.png', zorder: 800
    
    @player = PlayerShip.create ship: :Masta, weapons: [:grapple_hook]
    @player.warp(500, 500)
    # Turret.create x: 100, y: 200, ship: :Turret0,
    #   target: Asteroid, hostile: true, range: 1000
    # Turret.create x: 1300, y: 200, ship: :DefSat,
    #   target: Asteroid, hostile: true, range: 1000, weapons: [:bio_cannon]
    # Turret.create x: 100, y: 860, ship: :EyeBot,
    #   target: Asteroid, hostile: true, range: 1000, weapons: [:bio_cannon]
    #@player.equip :grapple_hook
    
    #Hostile.create x: 100, y: 200, ship: Ship[:Masta], target: Asteroid, hostile: true, weapons: [:cannonA]
    
    @debug_text, @keys_info, @ind = [], [], 0
    #add_debug_info 'Player pos, torque', proc { "#{@player.pos}, #{@player.body.t}" }
    #add_debug_info 'Cursor pos', proc { "#{@cursor.pos}" }
    
    #add_debug_info 'Turret angle', proc { "#{@player.body.a} : #{(@player.body.a.radians_to_gosu % 360).to_i} : #{(@player.body.a.radians_to_degrees % 360).to_i}" }
    
    #add_debug_info 'blah', proc { |a,p,c|
    #  ''
    #}
    
    
    keys_info '[ESC] Quit game'
    keys_info '[P] Start pry'
    keys_info '[T] Target new asteroid'
    keys_info '[A] Add new asteroid'
    
    self.input = {
      escape: :exit,
      p: -> { binding.pry },
      t: -> { Turret.all.each &:find_new_target },
      a: -> { Asteroid.create x: 500, y: 500 },
      holding_mouse_left: :lclick,
      holding_mouse_right: :rclick,
    } 
  end
  

  
  def lclick
    #@ast.body.apply_impulse(CP::Vec2.new(10, 0), CP::Vec2.new(0,0))
    #@player.turn_left
    # closest asteroid
    ca = Asteroid.all.sort_by { |a| a.pos.dist(@cursor.pos) }.first
    ca.explode if ca
  end
  
  def rclick
    #@player.turn_right
  end
  
  def draw
    super

  end

end
end
end
