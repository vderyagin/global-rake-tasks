def gists
  @gists ||=
    begin
      require 'json'
      require 'net/http'

      uri = URI('https://api.github.com/users/vderyagin/gists')
      JSON.parse(Net::HTTP.get(uri))
    end
end

def git_repo(uri, path)
  if File.directory?(path)
    update_git_repo(path)
  else
    clone_git_repo(uri, path)
  end
end

def update_git_repo(path)
  git_dir = File.expand_path('.git', path)
  work_tree = File.expand_path(path)

  command = [].tap do |cmd|
    cmd << 'git'
    cmd << "--git-dir=#{git_dir}"
    cmd << "--work-tree=#{work_tree}"
    cmd << 'pull'
  end

  sh(*command)
end

def clone_git_repo(uri, path)
  command = [].tap do |cmd|
    cmd << 'git'
    cmd << 'clone'
    cmd << uri
    cmd << File.expand_path(path)
  end

  sh(*command)
end

desc 'clone or update all my public gists'
task :gists do
  mkdir_p File.expand_path('~/code/gists')

  gists.each do |gist|
    repo_name = gist['files'].first.first
    repo_path = File.expand_path(repo_name, '~/code/gists')
    git_repo(gist['git_pull_uri'], repo_path)
  end
end
