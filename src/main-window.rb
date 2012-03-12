module SpaceGame

class MainWindow < Chingu::Window

  alias current current_game_state

  def initialize s = SpaceGame::ChooseGame
    super *$config['screen_size'], false
    #Gosu.enable_undocumented_retrofication
    
    push_game_state s
    #push_game_state SpaceGame::Tests::WormholeTest
    #push_game_state SpaceGame::Tests::GrapplingTest
  end
  
end
end
