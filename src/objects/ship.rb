
module SpaceGame
class Ship < PhysicsObject
trait :timer

W_LIMIT = 0.5 # limits the rotational velocity

  def self.[] key=nil
    ships[key] or raise "Invalid ship #{key.inspect}"
  end
  
  def self.ships
    @ships ||= YAML.load_file File.expand_path 'data/ships.yml'
  end
  
  attr_reader :ship_name, :health, :energy, :radius
  include PhysicsObject::Attachable

  def initialize options={}
    ship = options.delete(:ship) || nil
    if ship.is_a? Symbol then ship = Ship[ship] end
    raise "Invalid ship #{options}" unless ship.is_a? Hash
    
    options = {
      col_type: :ship,
      col_shape: :circle,
      mass: 10.0,
      slots: [],
      energy_rate: 150/30,
      inv: [],
      zorder: ZOrder::OBJECTS,

    }.merge(ship).merge(options)
    
    if options[:rotation_points]
      @rotation_points = options[:rotation_points]
      @anim = Animation64degree.animation options[:img], options[:size], options[:rotation_points]
      if options[:lock_col]
        @lock_col = options[:lock_col]
        @image = @anim[0][options[:lock_col]]
      elsif options[:roll]
        @roll = true
        @roll_range = -0.5 .. 0.5  # correspond to @body's ang_vel to get ship roll
        @image = @anim[0].first
      else
        @image = @anim[0].first
      end
    else
      @anim = Animation64degree[options[:img], options[:size]]
      @image = @anim.first
    end
    
    if !@image
    puts 'No image, wtf?'
    binding.pry
    end
    
    super options
    
    @health = @max_health = options[:armor].f
    @energy = @max_energy = options[:energy].f
    @inv = Inventory.new(options[:inv] || nil)
    @status, @stalled, @weapon_jam = ShipStatus.new, false, false
    
    @trate = options[:turning_rate] || 12
    @faccel = options[:faccel] || 45.0
    @baccel = options[:baccel] || 34.0
    @saccel = options[:saccel] || 28.0
    @boost_rate = options[:boost_rate] || 2.3 # holding shift
    unboost

    @body.w_limit = W_LIMIT
    
    every(150) {
      if @status.not(:EMP) && @energy < @max_energy
        @energy = [@energy + 30, @max_energy].min
      end
    }
    
    if options[:radius]
      @shape.set_radius!(options[:radius])
      @radius = options[:radius]
    else
      @radius = @image.width/2
    end
    
    @ship_name = options[:name]
    
    @weapons, @attach_i = [], 0
    options[:weapons].each { |m| equip m } if options[:weapons]
    
    if self.class == PlayerShip
      @tag = Chingu::Text.new 'Player',
        color: ::Gosu::Color::GREEN,
        font: "pricedown.ttf", size: 16
    else
      @tag = Chingu::Text.new @ship_name,
        color: ::Gosu::Color::RED,
        font: "pricedown.ttf", size: 16
        #font: "pricedown.ttf", size: 16
    end
    @health_tag = Chingu::Text.new "#{@health.round}/#{@max_health.i} hp",
      color: self.class == PlayerShip ? Gosu::Color::GREEN : Gosu::Color::RED,
      font: "pricedown.ttf", size: 16
      #font: "pricedown.ttf", size: 16
    
    if options[:thrust]
      options[:thrust][:offs] = options[:thrust][:offs].map { |v| CP::Vec2.new(*v) } unless options[:thrust][:offs][0].is_a? CP::Vec2
      options[:thrust][:anim] ||= Chingu::Animation.new(file: options[:thrust][:file], delay: options[:thrust][:delay])
      every(options[:thrust][:timer], name: :thrust) {
        options[:thrust][:offs].each { |v|
          Explosion.create pos: pos + @body.a.radians_to_vec2.rotate(v), \
            anim: options[:thrust][:anim], zorder: @zorder-1
        }
      }
    end
  end
  
  def future_pos()
    pos + (@body.vel * 10)
  end
  
  def hit_by(obj, dmg_factor = 1)
    return unless obj.damage
    energy_hit(obj.damage[:energy] * dmg_factor) if obj.damage[:energy]
    unless @options[:invincible]
      @health -= obj.damage[:health] * dmg_factor 
      explode if @health <= 0
    end
    @health_tag.text = "#{@health.round}/#{@max_health.i} hp"
    @status.add obj.damage[:status] if obj.damage.has_key?(:status)
  end
  
  def anim_angle() ((@body.a.radians_to_gosu%360)/360.0*@rotation_points).to_i end
  
  def grapple(ast)
    #create new dampedsprintg
    s = CP::Constraint::DampedSpring.new(
      @body, 
      ast.body, 
      CP::Vec2.new(0,0), 
      CP::Vec2.new(0,0),
      100.0, #rest_length
      0.2,
      0.9
    )
    #I leave it to the asteroid to remove itself
    s.add_to_space parent.space
    add_attachment(s, ast)
    #save the spring in the asteroid so it can be destroyed when the asteroid dies
    ast.add_attachment(s, self)
  end
  
  def update
    #p @shape.body.a.radians_to_gosu%360/360.0*64.0
    #p @shape.body.a.radians_to_gosu

    if @rotation_points
      if @roll
        #puts ((-@body.ang_vel + 0.5) * 10.0).round
        @image = @anim[anim_angle][((-@body.ang_vel + W_LIMIT) * 10.0).round]
      elsif @lock_col
        @image = @anim[anim_angle][@lock_col]
      else
        @image = @anim[anim_angle].first
      end
    end

    super

    @weapons.each { |w| w.update unless w.nil? }

    @stalled = @status.is? :STALL
    @weapon_jam = @status.is? :JAM
  end

  def draw
    @image.draw_rot x, y, 100, 0, @center_x, @center_y, scale, scale, @color rescue nil#binding.pry
    #$window.draw_circle *@body.pos, @shape.radius, ::Chingu::DEBUG_COLOR, 999
    unless @attachments.empty?
      a = @attachments[@attach_i = (@attach_i + 1) % @attachments.size]
      if @attachment_anim then
        (@attachment_anim.next).draw_rot
      else
        $window.draw_line x, y, Gosu::Color::WHITE,
                  a[1].x,a[1].y,Gosu::Color::WHITE,0 if a 
      end
    end
    #r = @health/@max_health
    #@energy = @max_energy if @options[:unlimited_energy]
    #e = @energy/@max_energy
    #binding.pry
    #$window.fill_rect [@x-(width/2), @y+(height/2), 30*r, 3], 0xff000000 + (0xff*r).to_i*256 + (0xff*(1-r)).to_i*256*256, 2
    #$window.fill_rect [x-(width/2), y+(height/2), r*radius*2, 3], 0xff000000 + (0xff*r).to_i*256 + (0xff*(1-r)).to_i*256*256, 2 unless r < 0
    #$window.fill_rect [@x-(width/2), @y+(height/2)+4, 30*e, 3], 0xff000000 + (0xff*e).to_i*256 + (0xff*(1-r)).to_i*256*256, 2
    #$window.fill_rect [x-(width/2), y+(height/2)+4, e*radius*2, 3], 0xff000000 + (0xff*e).to_i*256 + (0xff*(1-e)).to_i*256*256, 2 unless e < 0
    @tag.draw_at x-radius, y+radius
    @health_tag.draw_at x-radius, y+radius+12
  end
  
  def equip wpn = nil
    return unless wpn
    wpn = Weapon[wpn, self, @weapons.size]
    if wpn then @weapons << wpn; wpn
    else false end
  end
  
  def collect_item item
    @inv << item
    item.destroy
    @body.mass = @options[:mass] + @inv.weight
    @parent.push_sound Gosu::Sound['pickup2.wav'], pos
  end
  
  def shoot0 id=0
    @weapons[id].shoot if !@weapon_jam && @weapons[id]
  end
  def shoot1() shoot0(1) end
  def shoot2() shoot0(2) end
  def shoot3() shoot0(3) end
  def shoot4() shoot0(4) end
  def shoot5() shoot0(5) end
  
  def detach(id = 0)
    remove_last_attachment
  end
  
  def energy_hit(amt)
    @energy -= amt.to_f
    @energy = 0 if @energy < 0
  end
  
  def destroy
    super
  end
  
  def explode
    destroy
    after(200) do
      Debris.HappySetExplosion 0, x, y, 5.5..15, 4
    end
  end
  
  def boost
    @accelr = @boost_rate
  end
  
  def unboost
    @accelr = 1.0
  end
  
  def accel()
    @body.apply_force((@shape.body.a.radians_to_vec2 * (@faccel * @accelr)), CP::Vec2.new(0.0,0.0)) \
      unless @stalled
  end
  
  def decel()
    @body.apply_force(-(@shape.body.a.radians_to_vec2 * (@baccel * @accelr)), CP::Vec2.new(0.0,0.0)) \
      unless @stalled
  end
  
  def strafe_left()
    @body.apply_force(@body.a.radians_to_vec2.rperp * (@saccel * @accelr), CP::Vec2.new(0.0,0.0)) \
      unless @stalled
  end
  
  def strafe_right()
    @body.apply_force(@body.a.radians_to_vec2.perp * (@saccel * @accelr), CP::Vec2.new(0.0,0.0)) \
      unless @stalled
  end
  
  def turn_left()
    @body.t = -@trate unless @stalled
  end
  
  def turn_right()
    @body.t = @trate unless @stalled
  end
  
  def turn(rate = @trate)
    @body.t = rate unless @stalled
  end
  
  class ShipStatus
    Default = {
      EMP: 0, #energy freeze checked in energy update method
      JAM: 0, #weapon jam checked when firing (NOT DONE)
      STALL: 0}#ship jam checked in Ship#update
    def initialize() @statii = Default.dup end
    def is?(s)
      return true if @statii[s] > 0 && @statii[s] -= 1
      false
    end
    def not(s) !is?(s) end
    def add(s) #keep the sanity checks as light as possible
      @statii.has_key?(s[0]) && @statii[s[0]] += s[1] #ie none
    end
  end
  
  class Inventory
    attr_reader :weight
    def initialize(items = [], cache_anims = false)
      @anims = cache_anims
      @items = {}
      @weight = 0
      #@anims = opts[:cache_anims] || false
      items.each { |i| self << i } unless items.empty?
    end
  
    def <<(item)
      if @items.has_key?(item.class)
        @items[item.class][0] += 1
      else
        @items[item.class] = [
          1,
          item.weight,
          #keep a copy of the animation to show on the side of the screen
          @anims ? item.anim.dup : nil
        ]
      end
      adjust_weight item.weight
    end
    
    def count(item)
      return 0 unless @items.has_key(item.class)
      @items[item.class][0]
    end
    
    def adjust_weight(amt)
      @weight += amt
    end
    
    def calc_weight()
      w = 0
      @items.each { |k, v|
        w += v[0] * v[1]
      }
      @weight = w
    end
  end
end

class PlayerShip < Ship
include ::Chingu::Helpers::InputClient
  def initialize(o={})
    @gui_weapons = []
    super(o)
  end
  def setup
    inp = YAML.load_file(File.expand_path('./data/controls.yml'))
    scheme = $config['controls']
    raise "Invalid control scheme #{scheme} please set one in user_settings.yml that exists in data/controls.yml" \
      unless inp.has_key? scheme
    controls = {}
    inp[:chingu][:togglable].each { |s|
      #['boost', 'unboost']
      key = inp[scheme].delete s[0]
      controls[key.intern] = s[0].intern
      controls["released_#{key}".intern] = s[1].intern
    }
    self.input = controls.merge(Hash[inp[scheme].map { |meth, key|
      ["holding_#{key}".intern, meth.intern]
    }])
    
    offs = CP::Vec2.new(options[:radius], 0) #wtf? >:(
    @aiming_tick = Chingu::GameObject.new rotation_center: :bottom_center
    @aiming_tick.instance_eval do
      @anim = Chingu::Animation.new(file: 'aiming_tick_5x64.png', delay: 300)
      @image = @anim.first
      @offs = offs
      def update()
        @image = @anim.next
        super
      end
      def offs() @offs end
    end
  end
  
  def update
    super
    @aiming_tick.update
  end
  
  def draw
    super
    e = @energy / @max_energy
    $window.fill_rect [
      ($window.width/3)+parent.viewport.x.i, 
      ($window.height-7)+parent.viewport.y.i, 
      e*($window.width/3), 
      5], 0xff000000 + (0xff*e).to_i*256 + (0xff*(1-e)).to_i*256*256, 2 unless e < 0

    @aiming_tick.draw_relative *(pos + @body.a.radians_to_vec2.rotate(@aiming_tick.offs)), 900, (@body.a.radians_to_gosu%360)
=begin    
    @weapons.each_with_index { |w, i|
      if w.cooldown > 0
        progress = 1.0 - [(m.cooldown.f / m.max_cooldown), 0.0].max
        
        
      end
    }
=end
    @weapons.each_with_index { |w, i|
      if w 
        progress = 1.0 - [(w.cooldown.f / w.max_cooldown), 0.0].max
        if progress > 0
          $window.fill_rect [34, 10+30*i+20*(progress), 2, 20*(1-progress)], 0xffff0000, 1000000
        end
      end
    }
  end

  def equip(wpn = nil)
    if !wpn.nil? && (w = super(wpn)).is_a?(Weapon)
      #make a new sprite
      text = GuiOverlay::Text.create(w.name, size: 16, color: Gosu::Color::BLUE)
      text.x = $window.width - text.width
      text.y = $window.height-(16 * (1 + @gui_weapons.size))
      @gui_weapons << text
    end
  end
end
end
