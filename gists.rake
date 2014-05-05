def gists
  @gists ||=
    begin
      require 'json'
      require 'net/http'

      uri = URI('https://api.github.com/users/vderyagin/gists')
      JSON.parse(Net::HTTP.get(uri))
    end
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

desc 'clone my public gists'
task :gists do
  mkdir_p File.expand_path('~/code/gists')

  gists.each do |gist|
    repo_name = gist['files'].first.first
    repo_path = File.expand_path(repo_name, '~/code/gists')
    unless File.directory?(repo_path)
      clone_git_repo(gist['git_pull_uri'], repo_path)
    end
  end
end
