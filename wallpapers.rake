WALLPAPERS_DIRECTORY = File.expand_path '~/.wallpapers'
FEH_BG = File.expand_path '~/.fehbg'

# Return random wallpaper from WALLPAPERS_DIRECTORY.
def get_random_wallpaper
  Dir[File.join WALLPAPERS_DIRECTORY, '*'].sample
end

# Try to find wallpaper, last set by feh(1) as background, if failed - return
# random wallpaper.
def try_get_active_wallpaper
  if File.readable? FEH_BG
    wp = File.read(FEH_BG)[/(?<=').+(?=')/]
    return wp if File.exists?(String wp)
  end

  get_random_wallpaper
end

desc 'Lock current display using alock(1).'
task :lock_screen do
  wallpaper = try_get_active_wallpaper
  IO.popen ['alock', '-auth', 'pam', '-bg', "image:file=#{wallpaper}"]
end

namespace :wp do
  def set_wallpaper(wallpaper)
    IO.popen ['feh', '--bg-scale', wallpaper]
  end

  desc 'Randomly rename all wallpapers.'
  task :rename do
    require 'pathname'
    require 'securerandom'

    Pathname.glob File.join(WALLPAPERS_DIRECTORY, '*') do |old|
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

task :wp => 'wp:random'
