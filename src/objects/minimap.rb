module SpaceGame; class PhysicsState
# do not include Minimap without setting it up in the setup method..!
module Minimap
  #TODO configurab,e size
  def setup_minimap(order)
    @minimap_order = order
    @minimap = [
      TexPlay.create_blank_image($window, 200, 200),
      game_area[0]/200.0,
      game_area[1]/200.0,
      -1,  # index
      nil, # array of layers
      $window.width - (200 + 5), #screen pos x
      5,                         #screen pos y
    ]
    @minimap[4] = order.map { @minimap[0].dup }
    @minimap[0].each {|c| c[3] = 1}
  end

  def update
    super

    m = @minimap_order[(@minimap[3] = (@minimap[3] + 1) % @minimap_order.size)]
    @minimap[4][@minimap[3]].clear
    game_objects_of_class(m[0]).each { |e|
      @minimap[4][@minimap[3]].pixel \
        (e.x/@minimap[1]).to_i, 
        (e.y/@minimap[2]).to_i,
        color: m[1]
    }
  end

  def draw
    super
    @minimap[0].draw @minimap[5], @minimap[6], 700, 1,1
    @minimap[4].each_with_index { |img, i| img.draw @minimap[5], @minimap[6], 701+i, 1,1 }
  end
end

end; end
