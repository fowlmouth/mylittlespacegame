
module SpaceGame
module Animation64degree
  class << self
    def [] key, size = nil
      @animations ||= {}
      @animations[key] ||= Gosu::Image.load_tiles($window, Gosu::Image[key], *(size || key.match(/_(\d+)x(\d+)/)[1,2].map(&:to_i)), false)
    end
    
    def animation key, size=[], rot_points=64
      #builds an array of animations instead of flat array like above
      @animations ||= {}
      if @animations[key] then return @animations[key]
      else
        anim = Chingu::Animation.new(file: key, size: size)
        @animations[key] = (0..rot_points-1).map { |i|
          anim.frames[i*(anim.frames.size/rot_points), (anim.frames.size/rot_points)]
        }
      end
    end
  end
end
end
