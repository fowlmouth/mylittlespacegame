module SpaceGame
module Tests
module DebugGUI
  def keys_info str
    @keys_info << Chingu::Text.create(str, size: 14, y: @keys_info.size * 15)
    @keys_info.last.x = $window.width-@keys_info.last.width
  end

  def add_debug_info str, proc = nil, &block
    i = @debug_text.size
    @debug_text << [Chingu::Text.new(str, size: 14, x: 0, y: i * 15)]
    @debug_text[i][1] = Chingu::Text.new('', size: 14, x: @debug_text.last[0].width, y: i * 15)
    @debug_text[i][2] = proc || block
  end
  alias debug_text add_debug_info
  
  def initialize options={}
    super options
    @dt_ind, @debug_text, @keys_info = -1, [], []
  end
  
  def update
    super
    if @debug_text.size > 0
      d = @debug_text[@dt_ind = (@dt_ind + 1) % @debug_text.size]
      d[1].text = d[2].call
    end
  end
  
  def draw
    super
    @debug_text.each { |t| t[0].draw; t[1].draw }
  end

  class Cursor < Chingu::GameObject
    def initialize(opts={})
      opts[:image] ||= 'arrow.png'
      opts[:zorder] ||= 800
      opts[:rotation_center] ||= :top_left
      super opts
    end
    
    def pos() CP::Vec2.new(x, y) end
    def update
      @x, @y = $window.mouse_x - $window.mouse_x%16, $window.mouse_y - $window.mouse_y%16
    end
    #def update() @x, @y = x, y end
  end

end
end
end
