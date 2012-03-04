#!ruby
require 'gosu'
require 'chipmunk'
require 'chingu'
require 'texplay'
require 'slop'
require 'pry'

ROOT_DIR = File.expand_path(File.dirname __FILE__)
#I'll list data files I've renamed here
#so they can be iterated over and fixed
Dir.chdir "#{ROOT_DIR}/data"
#FILE_RENAMES = 
{
  %q&gfx/debris/ChunkE.png& => %q$gfx/debris/ChunkE_24x24.png$,
  %q,gfx/SkithzarMine.png,  => %q#gfx/bullets/SkithzarMine_32x32.png#,
}.each { |old, new|
  if File.exists?(old) && !File.exists?(new)
    puts "Renaming #{old} -> #{new}"
    File.rename old, new
  end
}
Dir.chdir ROOT_DIR

#TODO: time this
%w[ main-window zorder physics-state physicsobject staticobject animations weapon ].each { |f| require_relative "src/#{f}" }
%w[ ship aiships explosion bullet resource asteroid gascloud wormhole ].each { |f| require_relative "src/objects/#{f}" }
%w[ debug-gui asteroid-test ship-test static-test turret-test thrust-test wormhole-test grappling-test ].each { |f| require_relative "src/tests/#{f}" }

#gametype specific code is in here so separated 
#has to load last
require_relative "src/gamestate"
%w[ config-state menu-state ].each { |f| require_relative "src/gamestates/#{f}" }


Gosu::Image.autoload_dirs.unshift "#{ROOT_DIR}/data/gfx"
Gosu::Sound.autoload_dirs.unshift "#{ROOT_DIR}/data/sfx"
Gosu::Font.autoload_dirs.unshift "#{ROOT_DIR}/data/fnt"

$config = {
  gamepad: ARGV.include?('gp')
}

opts = Slop.parse do
  banner "Usage: main.rb [options]"
  on :t, :test, 'Run test', optional: true
  on :s, :ship, 'Use ship', true, optional: true
  on :g, :gamepad, 'Use gamepad (NOT READY)', optional: true
end

ship = opts[:ship] ? opts[:ship].intern : nil
if ship && SpaceGame::Ship.ships.has_key?(ship)
  $config[:ship] = ship
else
  $config[:ship] = :Hornet
end
puts "Using ship #{$config[:ship]}"

if RUBY_VERSION < '1.9.3'
  alias old_rand rand
  def rand(blah)
    if blah.is_a?(Range)
      Gosu.random(blah.min, blah.max)
    else
      old_rand(blah)
    end
  end
end

class Numeric
  def radians_to_vec2
    CP::Vec2.new(Math.cos(self), Math.sin(self))
  end
  
  def i() to_i end
  def f() to_f end
end

begin
  SpaceGame::MainWindow.new.show
rescue
  case RUBY_PLATFORM
  when /linux/
    #colorful backtrace :>
    puts
    puts "\e[31m#{$!.class}\e[0m: #{$!.message}"
    puts $!.backtrace.map { |z|
      z = z.split ':'
      z[0] = z[0].split('/')
      z[0] = z[0][-[z[0].size, 5].min..-1]
      z[0][-1] = "\e[35m#{z[0][-1]}\e[0m"
      z[1] = "\e[33m#{z[1]}\e[0m"
      "#{z[0].join('/')}:#{z[1]}:#{z[2]}"
    }.join("\n")
  when /mingw/
    puts "#{$!.class}: #{$!.message}"
    puts
    puts "  #{$!.backtrace.join "\n  "}"
  end
end
