def stale_bytecode?(source_file)
  bytecode = Pathname.new "#{source_file}c"
  bytecode.exist? && bytecode.mtime < source_file.mtime
end

namespace :emacs do
  desc 'locate stale and orphaned bytecode im  ~/.emacs.d directory.'
  task find_cruft: %i(find_stale_bytecode find_orphan_bytecode)

  desc 'Find stale elisp bytecode in ~/.emacs.d directory.'
  task :find_stale_bytecode do
    require 'pathname'

    wildcard = File.expand_path('~/.emacs.d/**/*.el')

    stale = Pathname.glob(wildcard)
      .select(&method(:stale_bytecode?))
      .map { |el| "#{el}c" }

    puts stale

    abort unless stale.empty?
  end

  desc 'Find elisp bytecode files lacking source in ~/.emacs.d directory.'
  task :find_orphan_bytecode do
    require 'pathname'

    wildcard = File.expand_path('~/.emacs.d/**/*.elc')

    orphans = Pathname.glob(wildcard).reject { |elc|
      Pathname.new(elc.to_s.chomp('c')).exist?
    }.map(&:to_s)

    puts orphans

    abort unless orphans.empty?
  end

  desc 'Recompile all emacs configuration files.'
  task :recompile_configs do
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

    wildcard = File.expand_path('~/.emacs.d/dotemacs/conf/**/*.elc')

    rm_f Dir[wildcard], verbose: false

    system(*command)            # Kernel#system is less noisy then FileUtils#sh
  end

  desc 'Regenerate all el-get autoloads.'
  task :regenerate_autoloads do
    init_file = File.expand_path '~/.emacs.d/dotemacs/misc/compile-init.el'

    command = []
    command << 'emacs'
    command << '--quick'
    command << '--load' << init_file
    command << '--batch'
    command << '--funcall' << 'el-get-regenerate-all-autoloads'

    sh(*command)
  end

  desc 'Delete all session persistance files.'
  task :delete_persisted_session do
    session = Rake::FileList.new.clear_exclude

    %w(
      .emacs.desktop
      .emacs.desktop.lock
      eshell/history
      eshell/lastdir
      ido-history
      org-clock-save.el
      recentf
      recentf~
      slime-repl-history
    ).each do |file|
      session.add File.expand_path(file, '~/.emacs.d')
    end

    session.existing!

    if session.empty?
      puts 'no files to delete.'
    else
      session.each(&method(:rm_r))
    end
  end
end
