module SpaceGame
module Tests
class CloudTest < PhysicsState

include DebugGUI

def setup
  game_area 1280, 1024
  
  
  @space.add_collision_func(:ship, :cloud) do |ship, cloud|
  # binding.pry
    ship.object.transparency 80
    cloud.object.transparency 75 if ship.object == @player
    #binding.pry if ship.object == @player && rand(200) == 1
  end
  
  
  @player = PlayerShip.create ship: :Asp, x: 100, y: 100
  
  Hostile.create ship: :Zag, target: Hostile, x: 200, y: 200
  Hostile.create ship: :Masta, target: Hostile, x: 300, y: 300
end

end; end; end
