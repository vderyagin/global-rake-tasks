=begin

Set of rake tasks for mounting/unmounting and querying status of certain encfs
(http://www.arg0.net/encfs) filesystems (specified by FILESYSTEMS hash).

Relies on presence of encfs(1), fusermount(1) and notify-send(1) command-line
tools.

=end

require_relative './lib/encfs/fs'

FAIL_ICON = File.expand_path '~/.icons/fail.png'

FILESYSTEMS = {
  ledger: '~',
  stuff:  '~/temp',
}

def filesystem(id)
  mount_dir = File.expand_path("#{id}.encfs", FILESYSTEMS[id])
  store = File.expand_path(id.to_s, '~/misc/encfs')
  EncFS::FS.new(store, mount_dir)
end

def mount_failed(fs)
  warn 'failed to mount encrypted filesystem.'

  sh(*[].tap do |cmd|
        cmd << 'notify-send'
        cmd << "Failed to mount encrypted filesystem \"#{fs}\""
        cmd << 'Try again'
        cmd << '-u' << 'critical'
        cmd << "--icon=#{FAIL_ICON}" if File.exist?(FAIL_ICON)
      end)
end

namespace :encfs do
  FILESYSTEMS.keys.each do |key|
    fs = filesystem(key)

    namespace key do
      desc "Mount encfs filesystem \"#{key}\""
      task :mount do
        fs.mount or mount_failed(key)
        Rake::Task["encfs:#{key}:status"].invoke
      end

      desc "Unmount encfs filesystem \"#{key}\""
      task :umount do
        fs.umount
        Rake::Task["encfs:#{key}:status"].invoke
      end

      desc "Tell whether encfs filesystem \"#{key}\" is mounted"
      task :status do
        puts fs
      end

      desc "Create \"#{key}\" encfs filesystem unless already exists"
      task :new do
        fs.create or warn "failed to create filesystem \"#{key}\""
      end
    end
  end

  desc 'Report status of each encfs filesystem'
  task :status do
    FILESYSTEMS.keys.each do |key|
      Rake::Task["encfs:#{key}:status"].invoke
    end
  end

  desc 'Unmount all mounted encfs filesystem'
  task :umount do
    FILESYSTEMS.keys.each do |key|
      Rake::Task["encfs:#{key}:umount"].invoke
    end
  end
end
