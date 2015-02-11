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

namespace :encfs do
  desc 'Mount encrypted directory.'
  task :mount do
    abort 'already mounted' if mounted?

    mkdir_p MOUNT_DIR

    command = [].tap do |cmd|
      cmd << 'encfs'
      cmd << ENCRYPTED_STORAGE
      cmd << MOUNT_DIR
      cmd << '--extpass="ssh-askpass-fullscreen encfs"'
      cmd << '--idle=60'                  # in minutes
      cmd << '--ondemand'
    end

    sh(*command) do |ok, _|
      mount_failed unless ok
    end

    Rake::Task['encfs:status'].invoke
  end

  desc 'Unmount encrypted directory.'
  task :umount do
    abort 'not mounted' unless mounted?

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

  desc 'Create encfs filesystem unless already exists.'
  task :new do
    abort 'already exists and mounted' if mounted?

    if File.exist?(ENCRYPTED_STORAGE) &&
       Dir.entries(ENCRYPTED_STORAGE).length > 2
      abort "'#{ENCRYPTED_STORAGE}' is not empty."
    end

    sh 'encfs', '--paranoia', ENCRYPTED_STORAGE, MOUNT_DIR do |ok, _|
      abort 'failed to create filesystem' unless ok
    end
  end
end

task encfs: 'encfs:mount'
