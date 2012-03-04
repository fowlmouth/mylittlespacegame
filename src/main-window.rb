module SpaceGame

SCREEN_SIZE = [1400, 960]

class MainWindow < Chingu::Window

  alias current current_game_state

  def initialize
    super *SCREEN_SIZE, false
    #Gosu.enable_undocumented_retrofication
    
    push_game_state SpaceGame::ChooseGame
    #push_game_state SpaceGame::Tests::WormholeTest
    #push_game_state SpaceGame::Tests::GrapplingTest
  end
  
end
end
