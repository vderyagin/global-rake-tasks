namespace :update do
  def update_git_repo(path)
    cd File.expand_path(path) do
      sh 'git', 'pull'
    end
  end

  desc 'Update rbenv installation'
  task rbenv: %i(ruby_build) do
    update_git_repo '~/.rbenv'
  end

  desc 'Update ruby-build plugin of rbenv'
  task :ruby_build do
    update_git_repo '~/.rbenv/plugins/ruby-build'
  end
end
