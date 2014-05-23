def stale_bytecode?(source_file)
  bytecode = Pathname.new "#{source_file}c"
  bytecode.exist? && bytecode.mtime < source_file.mtime
end

def init_file
  File.expand_path('~/.emacs.d/dotemacs/misc/compile-init.el')
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
    srcs = Dir[File.expand_path '~/.emacs.d/dotemacs/conf/**/*.el']

    command = [].tap do |cmd|
      cmd << 'emacs'
      cmd << '--quick'
      cmd << '--load' << init_file
      cmd << '--batch'
      cmd << '--funcall' << 'batch-byte-compile'

      srcs.each do |src|
        cmd << src
      end
    end

    wildcard = File.expand_path('~/.emacs.d/dotemacs/conf/**/*.elc')

    rm_f Dir[wildcard], verbose: false

    system(*command)            # Kernel#system is less noisy then FileUtils#sh
  end

  desc 'Recompile yasnippets'
  task :recompile_yasnippets do
    yas_file = File.expand_path '~/.emacs.d/dotemacs/conf/yasnippet-configuration.el'

    sh(*[].tap do |cmd|
          cmd << 'emacs'
          cmd << '--quick'
          cmd << '--load' << init_file
          cmd << '--load' << yas_file
          cmd << '--batch'
          cmd << '--funcall' << 'yas-recompile-all'
        end)
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

  desc 'update stuff managed by el-get'
  task el_get: %i(el_get:upgrade_self
                  el_get:upgrade_packages
                  el_get:regenerate_autoloads
                  recompile_configs)

  namespace :el_get do
    desc 'Upgrade el-get'
    task :upgrade_self do
      sh(*[].tap do |cmd|
            cmd << 'emacs'
            cmd << '--quick'
            cmd << '--load' << init_file
            cmd << '--batch'
            cmd << '--funcall' << 'el-get-self-update'
          end)
    end

    desc 'Upgrade all el-get packages'
    task :upgrade_packages do
      sh(*[].tap do |cmd|
            cmd << 'emacs'
            cmd << '--quick'
            cmd << '--load' << init_file
            cmd << '--batch'
            cmd << '--eval' << '(let ((el-get-default-process-sync t)) (el-get-update-all \'no-prompt))'
          end)
    end

    desc 'Regenerate all el-get autoloads.'
    task :regenerate_autoloads do
      sh(*[].tap do |cmd|
            cmd << 'emacs'
            cmd << '--quick'
            cmd << '--load' << init_file
            cmd << '--batch'
            cmd << '--funcall' << 'el-get-regenerate-all-autoloads'
          end)
    end
  end
end
