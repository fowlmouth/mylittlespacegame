module SpaceGame
module Tests
class ThrustTest < PhysicsState

include DebugGUI

  def setup
    @game_area = [1400, 960]
    
    @cursor = Cursor.create
    
    @player = PlayerShip.create ship: :Masta
    @player.warp 500, 500
    
    debug_text 'Cursor pos' do
      "#{@cursor.pos}"
    end
    
    self.input = {
      escape: :exit,
      p: -> { binding.pry },
    }
  end


end
end
end
