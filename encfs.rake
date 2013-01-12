=begin

Set of rake tasks for mounting/unmounting and querying status of certain encfs
(http://www.arg0.net/encfs) filesystem (specified by ENCRYPTED_DIR and
MOUNT_DIR constants).

Relies on presence of encfs(1), fusermount(1) and notify-send(1) command-line
tools.

=end

ENCRYPTED_DIR = File.expand_path '~/misc/crypt'
MOUNT_DIR = File.expand_path '~/temp/encrypted'
MTAB = '/etc/mtab'
FAIL_ICON = File.expand_path '~/.icons/fail.png'

namespace :encfs do
  def mount_failed
    puts 'failed to mount encrypted filesystem.'

    command = []
    command << 'notify-send'
    command << 'Failed to mount encrypted filesystem'
    command << 'Try again'
    command << '-u' << 'critical'
    command << "--icon=#{FAIL_ICON}" if File.exists? FAIL_ICON

    sh *command

    cleanup
  end

  def mounted?
    File.readlines(MTAB).any? { |line| line.include? MOUNT_DIR }
  end

  def cleanup
    rmdir MOUNT_DIR if File.exists? MOUNT_DIR
  end

  def ensure_mounted
    abort 'filesystem is not mounted.' unless mounted?
  end

  def ensure_not_mounted
    abort 'filesystem is already mounted.' if mounted?
  end

  desc 'Mount encrypted directory.'
  task :mount do
    ensure_not_mounted

    extpass_string = "ssh-askpass-fullscreen 'Enter password for #{ENCRYPTED_DIR}:'"
    timeout = 60                          # minutes

    mkdir MOUNT_DIR unless File.exists? MOUNT_DIR

    command = []
    command << 'encfs'
    command << ENCRYPTED_DIR
    command << MOUNT_DIR
    command << "--extpass=#{extpass_string}"
    command << "--idle=#{timeout}"
    command << '--ondemand'

    sh *command do |ok, res|
      mount_failed unless ok
    end

    Rake::Task['encfs:status'].invoke
  end

  desc 'Unmount encrypted directory.'
  task :umount do
    ensure_mounted

    sh 'fusermount', '-uz', MOUNT_DIR do |ok, res|
      abort 'failed to unmount' unless ok
    end

    cleanup

    Rake::Task['encfs:status'].invoke
  end

  desc 'Tell whether encrypted filesystem is mounted.'
  task :status do
    print MOUNT_DIR
    puts mounted? ? " is \e[1m\e[32mMOUNTED\e[0m" : " is \e[1m\e[31mNOT MOUNTED\e[0m"
  end
end

task :encfs => 'encfs:mount'
