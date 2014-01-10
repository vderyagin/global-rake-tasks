ENV['DISPLAY'] ||= ':0'

FEH_BG = File.expand_path '~/.fehbg'

def wallpapers_directory
  File.expand_path(ENV['WALLPAPERS_DIR']).tap do |dir|
    abourt "directory '#{dir}' does_not exist" unless File.directory?(dir)
  end
end

# Return random wallpaper from wallpapers_directory.
def random_wallpaper
  loop do
    Dir[File.join wallpapers_directory, '*'].sample.tap do |random_wp|
      return random_wp if active_wallpaper != random_wp
    end
  end
end

# Get wallpaper, last set by feh(1) as background, nil if failed.
def active_wallpaper
  @active_wapplaper ||=
    begin
      File.read(FEH_BG)[/(?<=').+(?=')/].tap do |wp|
        return unless File.exists?(String wp)
      end
    rescue Errno::ENOENT
      warn "No #{FEH_BG} found"
      nil
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

    Pathname.glob File.join(wallpapers_directory, '**/*.jpg') do |old|
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
