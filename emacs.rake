namespace :emacs do
  desc 'Find stale elisp bytecode in ~/.emacs.d directory.'
  task :find_stale_bytecode do
    require 'pathname'

    home = Pathname.new Dir.home

    stale = Pathname.glob(File.expand_path '.emacs.d/**/*.el', home).select { |el|
      elc = Pathname.new "#{el}c"
      elc.exist? and elc.mtime < el.mtime
    }.map { |el| "#{el}c" }

    puts stale

    abort unless stale.empty?
  end

  desc 'Find elisp bytecode files lacking source in ~/.emacs.d directory.'
  task :find_orphan_bytecode do
    require 'pathname'

    home = Pathname.new Dir.home

    orphans = Pathname.glob(File.expand_path '.emacs.d/**/*.elc', home).reject { |elc|
      Pathname.new(elc.to_s.chomp('c')).exist?
    }.map &:to_s

    puts orphans

    abort unless orphans.empty?
  end

  desc 'Recompile all emacs configuration files.'
  task :recompile_configs do
    require 'open3'

    init_file = File.expand_path '~/.emacs.d/dotemacs/misc/compile-init.el'
    srcs = Dir[File.expand_path '~/.emacs.d/dotemacs/conf/**/*.el']

    command = []
    command << 'emacs'
    command << '--quick'
    command << '--load' << init_file
    command << '--batch'
    command << '--funcall' << 'batch-byte-compile'

    srcs.each do |src|
      command << src
    end

    rm_f Dir[File.expand_path '~/.emacs.d/dotemacs/conf/**/*.elc'], verbose: false

    system *command            # Kernel#system is less noisy then FileUtils#sh
  end

  desc 'Regenerate all el-get autoloads.'
  task :regenerate_autoloads do
    require 'open3'

    init_file = File.expand_path '~/.emacs.d/dotemacs/misc/compile-init.el'

    command = []
    command << 'emacs'
    command << '--quick'
    command << '--load' << init_file
    command << '--batch'
    command << '--funcall' << 'el-get-regenerate-all-autoloads'

    sh *command
  end

  desc 'Delete all session persistance files.'
  task :delete_persisted_session do
    session = Rake::FileList.new.clear_exclude

    [
      '.emacs.desktop',
      '.emacs.desktop.lock',
      'eshell/history',
      'eshell/lastdir',
      'ido-history',
      'org-clock-save.el',
      'recentf',
      'recentf~',
      'savehist',
      'smex-items'
    ].each do |file|
      session.add File.expand_path(file, '~/.emacs.d')
    end

    session.existing!

    if session.empty?
      puts 'no files to delete.'
    else
      session.each &method(:rm_r)
    end
  end
end
