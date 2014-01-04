ENV['DISPLAY'] ||= ':0'

FEH_BG = File.expand_path '~/.fehbg'

def wallpapers_base_dir
  File.expand_path(ENV['WALLPAPERS_DIR']).tap do |dir|
    abourt "directory '#{dir}' does_not exist" unless File.directory?(dir)
  end
end

def wallpapers_directory
  File.expand_path(resolution, wallpapers_base_dir).tap do |dir|
    abort "directory '#{dir}' does not exist" unless File.directory?(dir)
  end
end

def resolution
  @res ||= `xrandr --query`[/(?<= connected )\d+x\d+/]
end

# Return random wallpaper from wallpapers_directory.
def random_wallpaper
  active = active_wallpaper

  loop do
    random = Dir[File.join wallpapers_directory, '*'].sample
    break random if active != random
  end
end

# Get wallpaper, last set by feh(1) as background, nil if failed.
def active_wallpaper
  File.read(FEH_BG)[/(?<=').+(?=')/].tap do |wp|
    return unless File.exists?(String wp)
  end
end

desc 'Lock current display using alock(1).'
task :lock_screen do
  (active_wallpaper || random_wallpaper).tap do |wp|
    IO.popen ['alock', '-auth', 'pam', '-bg', "image:file=#{wp}"]
  end
end

def use_wallpaper(wallpaper)
  IO.popen ['feh', '--bg-fill', wallpaper]
end

namespace :wp do
  desc 'Randomly rename all wallpapers.'
  task :rename do
    require 'pathname'
    require 'securerandom'

    Pathname.glob File.join(wallpapers_base_dir, '**/*.jpg') do |old|
      new_basename = SecureRandom.uuid + old.extname.downcase
      new_path = old.dirname + new_basename
      old.rename new_path
    end
  end

  desc 'Set random wallpater on current display using feh(1).'
  task :random do
    use_wallpaper random_wallpaper
  end

  desc 'Set last used wallpaper on current display using feh(1).'
  task :active do
    use_wallpaper(active_wallpaper || random_wallpaper)
  end
end

task wp: 'wp:random'
