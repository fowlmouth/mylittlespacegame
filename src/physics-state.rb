module SpaceGame
class PhysicsState < Chingu::GameState
  attr_reader :space, :player, :sound_queue, :whole_area
  
  trait :viewport

  trait :timer

  def initialize options={}
    super options
    @space = CP::Space.new
    @space.damping = 1.0 ## 0.85
    
    @space.add_collision_func(:ship, :ship, &nil)
    
    proc = proc { |bullet, obj|
      bullet.object.trigger obj.object
    }
    
    @space.add_collision_func(:bullet, :asteroid, &proc)
    @space.add_collision_func(:bullet, :ship, &proc)
    @space.add_collision_func(:bullet, :resource, &proc)
    
    @space.add_collision_func(:prize, :ship) do |r, ship|
      ship.object.collect_item(r.object)
      true
    end
    
    @sound_queue = []
    
    @borders = [0] # see #border() 
    
  end
  
  #options:
  #buffer_size => 50   give 50 pixels after the border to wrap around
  # :no_collide => [ :asteroid, :ship ] to let asteroids pass the border
  #
  #going to try to keep the implementation of this minimal so it doesnt
  #effect anything but PhysicsObject#wrap_pos which now looks for
  #this#whole_area
  #
  #returns buffer size if no opts are passed
  def border(buffer_size=nil, o = {})
    return @borders[0] unless buffer_size
    if @borders.size == 1
      w,h = game_area[0],game_area[1]
      body = CP::Body.new(Float::INFINITY, Float::INFINITY)
      @borders = [
        buffer_size,
        body, # border body obj
        [ #x, y, x, y
          [0, 0, w, 0 ], [w, 0, w, h ],
          [w, h, 0, h ], [0, h, 0, 0 ],
        ].map { |seg|
          # border segments :>
          CP::Shape::Segment.new body, vec2(*seg[0,2]), vec2(*seg[2,2]), 1
        }
      ].flatten 1
      @space.add_body @borders[1]
      @borders[2..-1].each { |s|
        s.e = o[:elasticity] || 0.96 #elasticity
        s.collision_type = :border
        @space.add_shape s
      }
      o[:no_collide].each { |ct|
        @space.add_collision_func(:border, ct) do |border, obj|
          if obj.object.has_attached?
            true #bounce off the border
          else false end #dont bounce
        end
      } if o[:no_collide]
      
      @whole_area = [
        w + @borders[0].*(2),
        h + @borders[0].*(2),
      ]
    end
    @borders[0]
  end
  
  def rand_x() rand(0..game_area[0]) end
  def rand_y() rand(0..game_area[1]) end
  
  def setup
    @viewport.game_area = [0, 0, *game_area]
    @viewport.center_around @player if @player
    @viewport.lag = 0.3
  end

  #returns to the first menu (or last?)
  def dat_menu() 
    game_states.size == 1 && exit #fires if this is the only gamestate
    Chingu::Text.create 'Now leaving :(', size: 48, x: 200, y: 200, color: Gosu::Color::RED
    after(500) { $window.pop_game_state(setup: false) }
  end
  
  def game_area(*args)
    unless args.empty?
      @whole_area= args unless @borders.size > 1
      @game_area = args
    else
      @game_area
    end
  end
  
  def update
    6.times { 
      @space.step(1.0/60.0)
    }
    game_objects_of_class(PhysicsObject).each { |go|
      go.reset_forces
      go.wrap_pos
#       if go.pos.x < @whole_area[0] \
#       || go.pos.y < @whole_area[2] \
#       || go.pos.x > @whole_area[1] \
#       || go.pos.y > @whole_area[3] then
#         go.body.pos = vec2(
    }
    
    super
    
    unless @sound_queue.empty?
      @sound_queue.each { |s, p|
        next unless p = sound_volume(p)
        s.play(p) if s
      }
      @sound_queue = []
    end
    
    @viewport.center_around @player
  end
  
  def push_sound snd, pos
    @sound_queue << [snd, pos]
  end
  
  #how does this work lol
  def sound_volume obj1, obj2 = @player
    ##pos = -((pos.dist(obj.pos)/3) * 0.001)+0.1
    #obj1 = -((obj1.dist(obj2.pos)/7) * 0.001)+0.1
    (obj1 = 0.1 - ((obj1.dist(obj2.pos)/7) * 0.001)) < 0 ? nil : obj1
  end
end
end
