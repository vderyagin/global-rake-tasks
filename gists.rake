def gists
  @gists ||=
    begin
      require 'json'
      require 'net/http'

      uri = URI('https://api.github.com/users/vderyagin/gists')
      JSON.parse(Net::HTTP.get(uri))
    end
end

desc 'clone my public gists'
task :gists do
  mkdir_p File.expand_path('~/code/gists')

  gists.each do |gist|
    repo_name = gist['files'].first.first
    repo_path = File.expand_path(repo_name, '~/code/gists')
    unless File.directory?(repo_path)
      sh 'git', 'clone', gist['git_pull_url'], repo_path
    end
  end
end
