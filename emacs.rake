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

    exit 1 unless stale.empty?
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

    Open3.popen2e *command do |input, output|
      output.each do |line|
        puts line if line =~ /^(Debugger entered|Error)/
        # puts line if line =~ /^Wrote/
      end
    end
  end
end
