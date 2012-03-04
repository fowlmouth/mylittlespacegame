module SpaceGame
class Game < PhysicsState

  MINIMAP_ORDER = [
    [Asteroid, :white],
    [AiShip, :red],
    [Bullet, :purple],
    [PlayerShip, :green]
  ]
  def setup
    #game_area 3000, 3000
    game_area 12_000, 12_000
    border 100, no_collide: [:asteroid], elasticity: 2.0
    @player = PlayerShip.create \
      ship: $config[:ship]
    #@player.equip :grapple_hook
    @player.warp 900, 700
    
    #@aiming_tick = Chingu::GameObject.new(file: 'ships/aiming_tick_5x64.png', size: [5, 64])
    
    5.times { 
      Asteroid.create x: Gosu.random(0,800), y: Gosu.random(0,600)
    }
    15.times { 
      Asteroid.create x: Gosu.random(game_area[0] - game_area[0]/3,game_area[0]), y: Gosu.random(0,game_area[1])
    }
    #10.times {
    #  GasCloud.create x: Gosu.random(1000,2000), y: Gosu.random(0,1000)
    #}
    
    Turret.create x: 1500, y: 1500, ship: :EyeBot, 
      target: PlayerShip
    
    Miner.create x: 100, y: 500, ship: :Zag,
      target: [Iron, Asteroid], hostile: true
    
    Hostile.create x: 100, y: 200, ship: :Zag,
      target: Asteroid
    Hostile.create x: 500, y: 200, ship: :Zag,
      target: Hostile
    Hostile.create x: 500, y: 500, ship: :Zag,
      target: Hostile
    
    5.times {
      Iron.create x: Gosu.random(0,3000), y: Gosu.random(0,3000)
    }
    10.times {
      MineralA.create x: Gosu.random(0,3000), y: Gosu.random(0,3000)
    }
    10.times {
      MineralB.create x: Gosu.random(0,3000), y: Gosu.random(0,3000)
    }
    #Turret.create x: 300, y: 300, ship: :Base0
    
    @stars = (0..3).map { |i|
      (0..3).map { |j|
        ::Gosu::Image["parallax/star0#{i}#{j}.png"]
      } << Gosu.random(1200,3000).to_i
    }.tap { |o|
      def o.p
        unless @parallax
          @parallax = Chingu::Parallax.new(x: -512, y: -512, factor: 1, zorder: 0)
          @parallax << {:image => 'parallax/star000.png', :repeat_x => true, :repeat_y => true, :rotation_center => :top_left, factor: 1}
          if true#$config[:stars] != :light
            @parallax << {:image => 'parallax/star011.png', :repeat_x => true, :repeat_y => true, :rotation_center => :top_left, :damping => 2, factor: 1}
            @parallax << {:image => 'parallax/star022.png', :repeat_x => true, :repeat_y => true, :rotation_center => :top_left, :damping => 3, factor: 1}
            @parallax << {:image => 'parallax/star033.png', :repeat_x => true, :repeat_y => true, :rotation_center => :top_left, :damping => 5, factor: 1}
          end
        end
        @parallax
      end
      
      def o.update
        each_with_index { |row, index|
          p.layers[index].image = row[::Gosu.milliseconds / row[-1] % (row.size - 1)]
        }
        p.update
      end
    }
    
    @minimap = [
      TexPlay.create_blank_image($window, 200, 200),
      game_area[0]/200.0,
      game_area[1]/200.0,
      -1,  # index
    ]
    @minimap[4] = MINIMAP_ORDER.map { @minimap[0].dup }
    @minimap[0].each {|c| c[3] = 1}
    
    self.input = {
      escape: :dat_menu,
      j: proc { @screen_shake = 150 }, # TODO: jitter.
      p: proc { binding.pry },
      i: proc { Asteroid.create x: x_rand, y: y_rand },
    }
    
    super
  end
  
  def update
    super
    
    if @stars
      @stars.p.camera_x = viewport.x.i
      @stars.p.camera_y = viewport.y.i
      @stars.update
    end
    
    if @minimap
      #my attempt at a layered minimap :P
      m = MINIMAP_ORDER[(@minimap[3] = (@minimap[3]+1)%MINIMAP_ORDER.size)]

      @minimap[4][@minimap[3]].clear

      @minimap[0].rect 0,0,200,200, fill: true, color: :black # if @minimap[3] == 0
      game_objects_of_class(m[0]).each do |e|
        @minimap[4][@minimap[3]].pixel (e.x/@minimap[1]).to_i, (e.y/@minimap[2]).to_i, :color => m[1]
      end
    end
    
    @viewport.center_around @player
    #Gosu::milliseconds / 100 % @animation.size
  end
  
  
  def draw
    #fill_rect [0,0,800,600], 0xff000001, -2
    super
    @stars.p.draw
    @minimap[0].draw SCREEN_SIZE[0]-205, 5, 700, 1,1#,Gosu::Color.rgba(255,255,255,128)
    @minimap[4].each_with_index { |image, i| image.draw SCREEN_SIZE[0]-205, 5, 701+i, 1, 1 }
  end
end
end
