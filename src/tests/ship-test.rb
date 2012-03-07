module SpaceGame
module Tests
class ShipTest < PhysicsState

include DebugGUI

def setup
  game_area 1280, 1024
  border 20, no_collision: [:bullet, :asteroid]
  
  @space.add_collision_func(:ship, :cloud) do |ship, cloud|
  # binding.pry
    ship.object.transparency 80
    cloud.object.transparency 75 if ship.object == @player
    #binding.pry if ship.object == @player && rand(200) == 1
  end
    
  
  @player = PlayerShip.create ship: :Asp, x: 100, y: 100
  
  Hostile.create ship: :Masta, target: Hostile, x: 300, y: 300
  Hostile.create ship: :Skithist, target: Hostile, x: 400, y: 200
  Hostile.create ship: :Tarthist, target: Hostile, x: 500, y: 100
  Hostile.create ship: :Kragath, target: Hostile, x: 600, y: 200
  
  Hostile.create ship: :Ravager, target: Hostile, x: 200, y: 700
  Hostile.create ship: :Hornet, target: Hostile, x: 300, y: 800
  Hostile.create ship: :Excelsior, target: Hostile, x: 400, y: 600
  Hostile.create ship: :Asp, target: Hostile, x: 500, y: 700
  
  Hostile.create ship: :Zag, target: Hostile, x: 800, y: 200
  Hostile.create ship: :Rak, target: Hostile, x: 800, y: 300
  Hostile.create ship: :Zap, target: Hostile, x: 800, y: 400
  Hostile.create ship: :Rip, target: Hostile, x: 800, y: 500
  
  game_objects_of_class(Ship).each { |s|
    s.instance_eval do @health = @health * 0.20 end 
  }

  self.input = {
    escape: :dat_menu,
    p: proc do binding.pry end,
  }

  super
end

end; end; end
