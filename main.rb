#!ruby
require 'gosu'
require 'chipmunk'
require 'chingu'
require 'texplay'
require 'pry'

ROOT_DIR = File.expand_path(File.dirname __FILE__)

#TODO: time this
%w[ main-window zorder physics-state physicsobject staticobject animations weapon ].each { |f| require_relative "src/#{f}" }
%w[ ship aiships explosion bullet resource asteroid gascloud wormhole gui-overlay ].each { |f| require_relative "src/objects/#{f}" }
%w[ debug-gui asteroid-test ship-test static-test turret-test thrust-test wormhole-test grappling-test ].each { |f| require_relative "src/tests/#{f}" }

#gametype specific code is in here so separated 
#has to load last
#  zones are final gamestates.. ie ready to play
%w[ test-zone1 ].each { |f| require_relative "src/zones/#{f}" }
%w[ config-state menu-state ].each { |f| require_relative "src/gamestates/#{f}" }

require_relative "data/data-manager.rb"

Gosu::Image.autoload_dirs.unshift "#{ROOT_DIR}/data/gfx"
Gosu::Sound.autoload_dirs.unshift "#{ROOT_DIR}/data/sfx"
Gosu::Font.autoload_dirs.unshift "#{ROOT_DIR}/data/fnt"

#default user config
$config = {
  'screen_size' => [1400, 960],
  'controls' => 'windows',
}
if File.exists?("#{ROOT_DIR}/user_settings.yml")
  $config = $config.merge(YAML.load_file "#{ROOT_DIR}/user_settings.yml")
elsif File.exists?("#{ROOT_DIR}/user_settings.yml.default")
  puts 'No user_settings.yml, using default settings'
  $config = $config.merge(YAML.load_file "#{ROOT_DIR}/user_settings.yml.default")
#else cry a lot and raise exceptions
end

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
  when /linux/, /darwin/
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
