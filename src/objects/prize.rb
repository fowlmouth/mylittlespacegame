
class Prize < Resource

  TYPE = [
    ['prize/SuperBombPrize_darkgreen_24x24.png', 'Cannon Upgrade'],
  ]
  
  def initialize opts={}
    prize = TYPE.sample
    @anim = Resource[prize[0], delay: Gosu.random(30, 90)]
    @image = @anim.first
    
    super opts
    
    #binding.pry
    @body.mass = 3
  end
  
end
