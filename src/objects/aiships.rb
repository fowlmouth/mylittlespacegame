module SpaceGame
class AiShip < Ship

  def initialize options={}
    super options
    options[:target] ||= self.class
    @hostile = options.has_key?(:hostile) ? options[:hostile] : nil
    @targets = [*options[:target]]
    @target_ind = 0
    @range = options[:range] || (@weapons[0] && @weapons[0].range) || 600
    @optimal = options[:optimal] || 500.0
    @target_wait_time = options[:target_wait] || 4000
  end 
  
  def find_new_target ind=0
    after(1000) {
      target = @targets[ind].all.sort_by { |lala|
        lala == self ? 9_999_999_999 : pos.distsq(lala.pos)
      }.first
      if target.nil?
        after(@target_wait_time) { find_new_target(ind == 0 && @targets.size > 1 ? rand(@targets.size).i : 0) }
      else
        @target = target
        stop_timer :alive
        every(1000, name: :alive) {
          if @target && @target.dead?
            puts "#@target is dead, finding new target."
            @target = nil
            find_new_target(@target_ind)
          end
        }
      end
    }
    @target
  end
  
  def hit_by(obj, factor = 1.0)
    super(obj, factor)
    if obj.from != @target
      @target = obj.from
    end
    #binding.pry
  end
  
  private
  def target obj=nil
    return self if obj && @target = obj
    diff = Math.atan2(@target.future_pos.y - y, @target.future_pos.x - x).radians_to_degrees
    diff = (diff - @body.angle.radians_to_degrees) % 360
    #puts "#{@ship_name} to #{@target.class} angle diff: #{diff.to_i}".rjust(80)# if false
    if diff < 180 then turn_right end
    if diff >= 180 then turn_left end
  end
  
  def move
    dist = pos.dist(@target.future_pos)
    if dist < @optimal then decel else accel end
    shoot0 if @hostile && dist <= @range
  end
end

class Hostile < AiShip
  def initialize options={}
    options[:hostile] = options.has_key?(:hostile) ? options[:hostile] : true
    super options
    find_new_target
  end  
  
  def update
    return super unless @target
    target
    move
    super
  end
end

class Turret < AiShip
  def initialize options={}
    options[:hostile] = options.has_key?(:hostile) ? options[:hostile] : true
    #options[:target_wait] ||= 200
    super options
    find_new_target
    @faccel = @baccel = 0
    @body.mass = Float::INFINITY
  end
  
  def update
    return unless @target
    target
    shoot0 if @hostile && pos.dist(@target.pos) <= @range && @target.health
    super
  end
  
  def draw
    super; draw_debug
  end
end

class Miner < AiShip
  def initialize options={}
    options[:hostile] = options.has_key?(:hostile) ? options[:hostile] : false
    options[:optimal] = 0
    super options
    find_new_target
  end
  
  def update
    if @target
      target 
      move
    end
    super
  end
end
end
