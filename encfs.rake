=begin

Set of rake tasks for mounting/unmounting and querying status of certain encfs
(http://www.arg0.net/encfs) filesystem (specified by ENCRYPTED_STORAGE and
MOUNT_DIR constants).

Relies on presence of encfs(1), fusermount(1) and notify-send(1) command-line
tools.

=end

ENCRYPTED_STORAGE = File.expand_path '~/misc/crypt'
MOUNT_DIR = File.expand_path '~/temp/encrypted'
MTAB = '/etc/mtab'
FAIL_ICON = File.expand_path '~/.icons/fail.png'

def mount_failed
  warn 'failed to mount encrypted filesystem.'

  sh(*[].tap do |cmd|
        cmd << 'notify-send'
        cmd << 'Failed to mount encrypted filesystem'
        cmd << 'Try again'
        cmd << '-u' << 'critical'
        cmd << "--icon=#{FAIL_ICON}" if File.exist?(FAIL_ICON)
      end)

  cleanup
end

def mounted?
  File.readlines(MTAB).any? { |line| line.include?(MOUNT_DIR) }
end

def cleanup
  rmdir MOUNT_DIR if File.exist?(MOUNT_DIR)
end

def ensure_mounted
  abort 'filesystem is not mounted.' unless mounted?
end

def ensure_not_mounted
  abort 'filesystem is already mounted.' if mounted?
end

namespace :encfs do
  desc 'Mount encrypted directory.'
  task :mount do
    ensure_not_mounted

    mkdir_p [ENCRYPTED_STORAGE, MOUNT_DIR]

    extpass_string =
      "ssh-askpass-fullscreen 'Enter password for #{ENCRYPTED_STORAGE}:'"

    timeout = 60                          # minutes

    command = [].tap do |cmd|
      cmd << 'encfs'
      cmd << ENCRYPTED_STORAGE
      cmd << MOUNT_DIR
      cmd << "--extpass=#{extpass_string}"
      cmd << "--idle=#{timeout}"
      cmd << '--ondemand'
    end

    sh(*command) do |ok, _|
      mount_failed unless ok
    end

    Rake::Task['encfs:status'].invoke
  end

  desc 'Unmount encrypted directory.'
  task :umount do
    ensure_mounted

    sh 'fusermount', '-uz', MOUNT_DIR do |ok, _|
      abort 'failed to unmount' unless ok
    end

    cleanup

    Rake::Task['encfs:status'].invoke
  end

  desc 'Tell whether encrypted filesystem is mounted.'
  task :status do
    print MOUNT_DIR
    if mounted?
      puts " is \e[1m\e[32mMOUNTED\e[0m"
    else
      puts " is \e[1m\e[31mNOT MOUNTED\e[0m"
    end
  end
end

task encfs: 'encfs:mount'
