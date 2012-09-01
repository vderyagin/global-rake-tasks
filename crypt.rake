ENCRYPTED_DIR = File.expand_path '~/misc/crypt'
MOUNT_DIR = File.expand_path '~/temp/encrypted'
MTAB = '/etc/mtab'
FAIL_ICON = File.expand_path '~/.icons/fail.png'

namespace :crypt do
  def mount_failed

    puts 'failed to mount encrypted filesystem.'

    command = []
    command << 'notify-send'
    command << 'Failed to mount encrypted filesystem'
    command << 'Try again'
    command << '-u' << 'critical'
    command << "--icon=#{FAIL_ICON}"

    IO.popen command

    cleanup
  end

  def mounted?
    File.readlines(MTAB).any? { |line| line.include? MOUNT_DIR }
  end

  def check_if_already_mounted
    if mounted?
      IO.popen ['notify-send', 'Filesystem is already mounted']
    end
  end

  def cleanup
    rmdir MOUNT_DIR if File.exists? MOUNT_DIR
  end

  desc 'Mount encrypted directory.'
  task :mount do
    check_if_already_mounted

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

    IO.popen(command).close

    if $? == 0
      puts 'filesystem mounted successfully.'
    else
      mount_failed
    end
  end

  desc 'Unmount encrypted directory.'
  task :umount do
    unless mounted?
      puts 'filesystem is not mounted.'
      exit
    end

    if File.directory? MOUNT_DIR
      IO.popen(['fusermount', '-uz', MOUNT_DIR]).close
    end

    cleanup
  end

  desc 'Tell whether encrypted filesystem is mounted.'
  task :status do
    print MOUNT_DIR
    puts mounted? ? " is \e[1m\e[32mMOUNTED\e[0m" : " is \e[1m\e[31mNOT MOUNTED\e[0m"
  end
end
