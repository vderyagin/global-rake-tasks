def installed_gems
  IO.popen(%w(gem list --no-version))
    .readlines
    .map(&:chomp)
end

def builtin_gems
  %w(
    bigdecimal
    io-console
    json
    minitest
    psych
    rake
    rdoc
    test-unit
  )
end

def default_gems
  %w(
    awesome_print
    bundler
    chef
    devel-which
    interactive_editor
    nrename
    pry
    pry-plus
    rake
    rcodetools
    rubocop
    t
    thor
    travis
    travis-lint
    twitter
  )
end

namespace :gem do
  desc 'Update rubygems'
  task :update_rubygems do
    sh 'gem', 'update', '--system'
  end

  desc 'Install some universally needed gems.'
  task :install_default do
    gems_to_install = default_gems - installed_gems

    if gems_to_install.empty?
      warn 'all default gems are installed already'
    else
      sh 'gem', 'install', *gems_to_install
    end
  end

  desc 'Update gems installed by default.'
  task :update_default do
    sh 'gem', 'update', *default_gems
  end

  desc 'Uninstall all gems.'
  task :uninstall_all do
    args = %w(uninstall --all --executables --ignore-dependencies)
    gems = installed_gems - builtin_gems

    if gems.empty?
      warn 'no gems to uninstall'
    else
      sh 'gem', *args, *gems
    end
  end
end

task gem: ['gem:update_rubygems',
           'gem:install_default',
           'gem:update_default'] do
  sh 'gem', 'cleanup'
end
