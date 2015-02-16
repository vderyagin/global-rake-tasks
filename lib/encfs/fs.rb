module EncFS
  class FS
    attr_reader :mount_dir

    def initialize(store, mount_dir, idle_time: 60)
      @store = File.expand_path(store)
      @mount_dir = File.expand_path(mount_dir)
      @idle_time = idle_time
    end

    def mounted?
      File.read('/etc/mtab').include?(@mount_dir)
    end

    def mount
      return true if mounted?

      Dir.mkdir(@mount_dir) unless File.exist?(@mount_dir)
      system(*[].tap do |cmd|
                cmd << 'encfs'
                cmd << @store
                cmd << @mount_dir
                cmd << '--extpass=ssh-askpass-fullscreen encfs'
                cmd << "--idle=#{@idle_time}"     # in minutes
              end).tap { |success| cleanup unless success }
    end

    def umount
      return true unless mounted?

      (system 'fusermount', '-uz', @mount_dir).tap { cleanup }
    end

    def cleanup
      Dir.rmdir @mount_dir if File.exist?(@mount_dir)
    end

    def to_s
      @mount_dir + ' is ' +
        if mounted?
          "\e[1m\e[32mMOUNTED\e[0m"
        else
          "\e[1m\e[31mNOT MOUNTED\e[0m"
        end
    end

    def create
      return true if mounted?

      if File.exist?(@store) && Dir.entries(@store).length > 2
        warn "#{@store} exists and is not empty"
        return
      end

      system 'encfs', '--paranoia', @store, @mount_dir
    end
  end
end
