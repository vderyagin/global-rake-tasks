ENV['DISPLAY'] ||= ':0'

WALLPAPERS_BASE_DIRECTORY = File.expand_path('~/.wallpapers')
FEH_BG = File.expand_path '~/.fehbg'

def wallpapers_directory
  dir = File.expand_path(resolution, WALLPAPERS_BASE_DIRECTORY)
  abort "directory '#{dir}' does not exist" unless File.directory?(dir)
  dir
end

def resolution
  @res ||= `xrandr --query`[/(?<= connected )\d+x\d+/]
end

# Return random wallpaper from wallpapers_directory.
def get_random_wallpaper
  active = get_active_wallpaper

  loop do
    random = Dir[File.join wallpapers_directory, '*'].sample
    break random if active != random
  end
end

def try_get_active_wallpaper
  get_active_wallpaper || get_random_wallpaper
end

# Get wallpaper, last set by feh(1) as background, nil if failed.
def get_active_wallpaper
  wp = File.read(FEH_BG)[/(?<=').+(?=')/]
  wp if File.exists?(String wp)
end

desc 'Lock current display using alock(1).'
task :lock_screen do
  wallpaper = try_get_active_wallpaper
  IO.popen ['alock', '-auth', 'pam', '-bg', "image:file=#{wallpaper}"]
end

namespace :wp do
  def set_wallpaper(wallpaper)
    IO.popen ['feh', '--bg-center', wallpaper]
  end

  desc 'Randomly rename all wallpapers.'
  task :rename do
    require 'pathname'
    require 'securerandom'

    Pathname.glob File.join(WALLPAPERS_BASE_DIRECTORY, '**/*.jpg') do |old|
      new_basename = SecureRandom.uuid + old.extname.downcase
      new_path = old.dirname + new_basename
      old.rename new_path
    end
  end

  desc 'Set random wallpater on current display using feh(1).'
  task :random do
    set_wallpaper get_random_wallpaper
  end

  desc 'Set last used wallpaper on current display using feh(1).'
  task :active do
    set_wallpaper try_get_active_wallpaper
  end
end

task wp: 'wp:random'
