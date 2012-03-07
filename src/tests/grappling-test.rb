module SpaceGame
module Tests
class GrapplingTest < PhysicsState

include DebugGUI

  def setup
    game_area 1400, 960
    border 100, no_collide: [:asteroid, :resource]
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
    @can_lclick, @can_rclick = true, true
    #add_debug_info 'Player pos, torque', proc { "#{@player.pos}, #{@player.body.t}" }
    #add_debug_info 'Cursor pos', proc { "#{@cursor.pos}" }
    
    #add_debug_info 'Turret angle', proc { "#{@player.body.a} : #{(@player.body.a.radians_to_gosu % 360).to_i} : #{(@player.body.a.radians_to_degrees % 360).to_i}" }
    
    #add_debug_info 'blah', proc { |a,p,c|
    #  ''
    #}

    @debris_force_min = 18
    @debris_force_max = 30

    add_debug_info 'Debris min force' do "#@debris_force_min" end
    add_debug_info 'Debris max force' do "#@debris_force_max" end
    
    
    keys_info '[ESC] Quit game'
    keys_info '[P] Start pry'
    keys_info '[T] Target new asteroid'
    keys_info '[I] Add new asteroid'
    keys_info '[Y] Raise Min debris force'
    keys_info '[H] Lower Min debris force'
    keys_info '[U] Raise Max debris force'
    keys_info '[J] Lower Max debris force'
    keys_info '[RCLICK] debris explosion'
    keys_info '[LCLICK] blow up asteroid'
    
    self.input = {
      escape: :dat_menu,
      p: -> { binding.pry },
      t: -> { Turret.all.each &:find_new_target },
      i: -> { Asteroid.create x: 500, y: 500 },
      holding_mouse_left: :lclick,
      holding_mouse_right: :rclick,
      y: :raise_min,
      h: :lower_min,
      u: :raise_max,
      j: :lower_max
    } 

    Terrain.create(x: 500, y: 500,
      terrain: :goal,
      width: 300, 
      height: 50) do |terrain, obj|
      if obj.object.is_a? Resource
        # score points
      end
      false
    end
  end
  
  def raise_min(by=5) @debris_force_min += by end
  def lower_min(by=5) raise_min -by end
  def raise_max(by=5) @debris_force_max += by end
  def lower_max(by=5) raise_max -by end
  
  def lclick
    #@ast.body.apply_impulse(CP::Vec2.new(10, 0), CP::Vec2.new(0,0))
    #@player.turn_left
    # closest asteroid
    return unless @can_lclick
    @can_lclick = false
    ca = game_objects_of_class(Asteroid).sort_by { |a| a.pos.dist(@cursor.pos) }.first
    #ca = Asteroid.all.sort_by { |a| a.pos.dist(@cursor.pos) }.first
    ca.explode if ca
    after(500) { @can_lclick = true }
  end
  
  def rclick
    #@player.turn_right
    return unless @can_rclick
    @can_rclick = false
    Debris.HappySetExplosion 0, @cursor.x, @cursor.y, @debris_force_min..@debris_force_max, 4
    after(500) { @can_rclick = true }
  end

#describes a poly area on the map that interacts by collision
class Terrain < SpaceGame::PhysicsObject
  def initialize opts = {}, &block
    if opts[:terrain].nil?
      opts[:terrain] = :"hihi"
    end

    super({
      col_type: opts[:terrain],
      col_shape: :rect,
      mass: Float::INFINITY,
      }.merge opts)

    @width, @height = opts[:width], opts[:height]

    init_physics

    @parent.space.add_collision_func(opts[:terrain], :ship, &block) if block

    #binding.pry
  end

  def width()  @width  end
  def height() @height end

  def draw
    super
    draw_debug
  end
  DebugColors = [
    Gosu::Color::RED, Gosu::Color::BLUE,
    Gosu::Color::GREEN,Gosu::Color::YELLOW
  ]
  def draw_debug()
    a = @body.a.radians_to_vec2
      @shape.num_verts.times { |v|
        point = @body.pos + @shape.vert(v).rotate(a)
        $window.draw_circle point.x, point.y, 2, DebugColors[v]#::Chingu::DEBUG_COLOR#, 999
      }
    end
end

end
end
end
