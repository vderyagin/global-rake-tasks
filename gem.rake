namespace :gem do
  DEFAULT_GEMS = %w(
    awesome_print
    bundler
    devel-which
    heroku
    interactive_editor
    nrename
    pry
    pry-doc
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
    all_gems = IO.popen(%w(gem list --no-version)).readlines.map(&:chomp)

    sh 'gem', *args, *all_gems
  end
end
