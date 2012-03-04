module SpaceGame
class Weapon
  
  class << self
    def [] key=nil, *args
      @weapons ||= YAML.load_file(File.expand_path 'data/weapons.yml')
      if @weapons.has_key? key
        unless args.empty?
          Weapon.new @weapons[key], *args
        else
          @weapons[key]
        end
      else
        raise "Invalid weapon: #{key}"
      end
    end
    
    def weapons() @weapons end
  end
  
  def initialize options={}, ship=nil, shipslot=nil
    if shipslot && shipslot > ship.options[:slots].size then return false end
  
    @ship = ship
    
    @bullet = Bullet[options[:bullet] || :bulletA]
    @energy_cost = options[:energy_cost] || 0
    
    #p options
    @offs = vec2(*(ship.options[:slots][shipslot][:offs] or ship.options[:slots][0][:offs])) if shipslot
    
    @max_cooldown = options[:cooldown]
    @cooldown = 0
    
    @recoil = options[:recoil] || 0
    @reload = options[:reload] || nil
    @range = options[:range] || range
    @optimal_range = options[:optimal_range] || optimal_range
    @fire_sound = ::Gosu::Sound[options[:fire_sound]]
    
    @multi = if options[:multi]
      @spread = options[:spread_mode] || :side
      options[:multi]
    else false
    end
    
    @rounds = if options[:rounds]
      @spent = 0
      @subcooldown = @max_cooldown
      options[:rounds]
    else false
    end
  end
  
  def shoot()
    return nil unless @cooldown <= 0
    
    if @energy_cost > @ship.energy
      return
    else
      @ship.energy_hit @energy_cost
    end
    
    if @multi
      case @spread_mode
      when :side
        pos = @ship.pos + @ship.body.a.radians_to_vec2.rotate(@offs)
        @multi.times { |i|
          Bullet.create(pos: pos.rotate((i*(360.0/@multi)).to_i), bullet: @bullet, from: @ship)
          
          #spr*i-(@type[:multi]-1)*spr/2 + @off[0]
        }
      end
    else
      pos = @ship.pos + @ship.body.a.radians_to_vec2.rotate(@offs)
      Bullet.create(pos: pos, bullet: @bullet, from: @ship)#, offs: @offs)
    end
        
    @cooldown = @max_cooldown
    if @rounds
      @spent += 1
      if @spent >= @rounds
        @cooldown = @max_cooldown = @reload
        @spent = 0
      else
        @max_cooldown = @subcooldown
      end
    end
    
    $window.current.push_sound @fire_sound, pos if @fire_sound
    
    true
  end
  
  def range()
    @range || @bullet[:speed] * @bullet[:timer]
  end
  
  def optimal_range()
    @optimal_range || @bullet[:speed] * @bullet[:timer]
  end
  
  def update() @cooldown -= 1 unless @cooldown == 0 end
end


end
