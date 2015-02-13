=begin

Set of rake tasks for mounting/unmounting and querying status of certain encfs
(http://www.arg0.net/encfs) filesystems (specified by FILESYSTEMS hash).

Relies on presence of encfs(1), fusermount(1) and notify-send(1) command-line
tools.

=end

MTAB = '/etc/mtab'
FAIL_ICON = File.expand_path '~/.icons/fail.png'

FILESYSTEMS = {
  ledger: '~',
  stuff:  '~/temp',
}

def mount_dir(fs)
  File.expand_path(fs.to_s + '.encfs', FILESYSTEMS.fetch(fs))
end

def encrypted_dir(fs)
  File.expand_path(fs.to_s, '~/misc/encfs')
end

def status(fs)
  "\"#{fs}\" is " +  if mounted?(fs)
                       "\e[1m\e[32mMOUNTED\e[0m"
                     else
                       "\e[1m\e[31mNOT MOUNTED\e[0m"
                     end
end

def mount_failed(fs)
  warn 'failed to mount encrypted filesystem.'

  sh(*[].tap do |cmd|
        cmd << 'notify-send'
        cmd << 'Failed to mount encrypted filesystem'
        cmd << 'Try again'
        cmd << '-u' << 'critical'
        cmd << "--icon=#{FAIL_ICON}" if File.exist?(FAIL_ICON)
      end)

  cleanup fs
end

def mounted?(fs)
  File.readlines(MTAB).any? { |line| line.include?(mount_dir(fs)) }
end

def cleanup(fs)
  dir = mount_dir(fs)
  rmdir dir if File.exist?(dir)
end

namespace :encfs do
  FILESYSTEMS.keys.each do |fs|
    namespace fs do
      desc "Mount encfs filesystem \"#{fs}\""
      task :mount do
        abort 'already mounted' if mounted?(fs)

        mkdir_p mount_dir(fs)

        command = [].tap do |cmd|
          cmd << 'encfs'
          cmd << encrypted_dir(fs)
          cmd << mount_dir(fs)
          cmd << '--extpass=ssh-askpass-fullscreen encfs'
          cmd << '--idle=60'                  # in minutes
          cmd << '--ondemand'
        end

        sh(*command) do |ok, _|
          mount_failed(fs) unless ok
        end

        Rake::Task["encfs:#{fs}:status"].invoke
      end

      desc "Unmount encfs filesystem \"#{fs}\""
      task :umount do
        abort 'not mounted' unless mounted?(fs)

        sh 'fusermount', '-uz', mount_dir(fs) do |ok, _|
          abort 'failed to unmount' unless ok
        end

        cleanup(fs)

        Rake::Task["encfs:#{fs}:status"].invoke
      end

      desc "Tell whether encfs filesystem \"#{fs}\" is mounted"
      task :status do
        puts status(fs)
      end

      desc "Create \"#{fs}\" encfs filesystem unless already exists"
      task :new do
        abort 'already exists and mounted' if mounted?(fs)

        if File.exist?(encrypted_dir(fs)) &&
           Dir.entries(encrypted_dir(fs)).length > 2
          abort "#{encrypted_dir(fs)} is not empty"
        end

        sh 'encfs', '--paranoia', encrypted_dir(fs), mount_dir(fs) do |ok, _|
          abort 'failed to create filesystem' unless ok
        end
      end
    end
  end

  desc 'Report status of each encfs filesystem'
  task :status do
    FILESYSTEMS.keys.each do |fs|
      puts status(fs)
    end
  end

  desc 'Unmount all mounted encfs filesystem'
  task :umount do
    FILESYSTEMS.keys.select(&method(:mounted?)).each do |fs|
      abort 'not mounted' unless mounted?(fs)

      sh 'fusermount', '-uz', mount_dir(fs) do |ok, _|
        abort 'failed to unmount' unless ok
      end

      cleanup(fs)
    end

    FILESYSTEMS.keys.each do |fs|
      Rake::Task["encfs:#{fs}:status"].invoke
    end
  end
end
