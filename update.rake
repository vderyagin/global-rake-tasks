namespace :update do
  def update_git_repo(path)
    git_dir = File.expand_path(File.join(path, '.git'))
    work_tree = File.expand_path(path)

    command = []

    command << 'git'
    command << "--git-dir=#{git_dir}"
    command << "--work-tree=#{work_tree}"
    command << 'pull'

    sh *command
  end

  desc 'Update rbenv installation'
  task :rbenv => :ruby_build do
    update_git_repo '~/.rbenv'
  end

  desc 'Update ruby-build plugin of rbenv'
  task :ruby_build do
    update_git_repo '~/.rbenv/plugins/ruby-build'
  end
end
