namespace :gem do
  DEFAULT_GEMS = %w(
    awesome_print
    bundler
    devel-which
    interactive_editor
    nrename
    pry
    pry-plus
    rake
    rcodetools
    rubocop
    thor
    travis
    travis-lint
    twitter
  )

  desc 'Install some universally needed gems.'
  task :install_default do
    sh 'gem', 'install', *DEFAULT_GEMS
  end

  desc 'Update gems installed by default.'
  task :update_default do
    sh 'gem', 'update', *DEFAULT_GEMS
  end

  desc 'Uninstall all gems.'
  task :uninstall_all do
    args = %w(uninstall --all --executables --ignore-dependencies)
    gems = all_gems - builtin_gems

    if gems.empty?
      warn 'no gems to uninstall'
    else
      sh 'gem', *args, *gems
    end
  end

  def all_gems
    IO.popen(%w(gem list --no-version)).readlines.map(&:chomp)
  end

  def builtin_gems
    %w(
      test-unit
      psych
      rdoc
      io-console
      json
      bigdecimal
      rake
      minitest
    )
  end
end
