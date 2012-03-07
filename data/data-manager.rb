#!ruby

#This should help keep things sane until the data is all sorted
#and such. included from main.rb
#run by itself to report on missing files

file_renames = {

#each data file that needs to be renamed should be listed here

%q&gfx/debris/ChunkE.png& => %q$gfx/debris/ChunkE_24x24.png$,
%q,gfx/SkithzarMine.png,  => %q#gfx/bullets/SkithzarMine_32x32.png#,

%q;gfx/doors/EnergyDoorVert.png; => %q=gfx/doors/EnergyDoorVert_16x32.png=,
%q%gfx/doors/EnergyDoorVert2.png% => %q@gfx/doors/EnergyDoorVert_16x64.png@,
%q^gfx/doors/EnergyDoorVert4.png^ => %q\gfx/doors/EnergyDoorVert_16x128.png\,
%q&gfx/doors/EnergyDoorVert8.png& => %q$gfx/doors/EnergyDoorVert_16x256.png$,

%q,gfx/doors/EnergyDoorHorz.png, => %q#gfx/doors/EnergyDoorHorz_32x16.png#,
%q;gfx/doors/EnergyDoorHorz2.png; => %q=gfx/doors/EnergyDoorHorz_64x16.png=,
%q%gfx/doors/EnergyDoorHorz4.png% => %q@gfx/doors/EnergyDoorHorz_128x16.png@,
%q^gfx/doors/EnergyDoorHorz8.png^ => %q\gfx/doors/EnergyDoorHorz_256x16.png\,


}

where_i_was = Dir.pwd
Dir.chdir File.dirname(__FILE__)

file_renames.each { |old, new|
  (
    puts "Renaming #{old} -> #{new}"
    File.rename old, new
  ) if File.exists?(old) && !File.exists?(new)
}

if __FILE__ == $0
#try to find files missing from *.yml files
  require 'yaml'
  
  @keys = {
    img: 'gfx',
    file: 'gfx',
    fire_sound: 'sfx',
  }
  files = %w:bullets.yml ships.yml weapons.yml:
  @missing_files = []
  def chk(hash, depth = [])
    hash.each { |k, v|
      if v.is_a? Hash
        chk v, depth + [k]
      elsif @keys.has_key?(k) \
      && v.is_a?(String) \
      && v =~ /.*\..+/ 
        if !File.exists?("#{@keys[k]}/#{v}")
          @missing_files << "#{depth.join('/')} references missing #{@keys[k]}/#{v}"
        end
      end
    }
  end
  files.each { |f| chk(YAML.load_file(f), [f]) }
  unless @missing_files.empty?
    puts @missing_files.join "\n"
    puts "Total #{@missing_files.size} missing files"
  else
    puts "No missing files found"
  end
  exit
end

Dir.chdir where_i_was