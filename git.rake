namespace :git do
  def find_git_repo_root
    current_directory = Dir.pwd

    until current_directory == '/'
      return current_directory if File.directory? '.git'
      current_directory = File.expand_path '..', current_directory
    end

    abort 'you are not in a git repository'
  end

  desc 'List files in git repository with number of changes.'
  task :churn do
    repo_root = find_git_repo_root

    IO.popen('git log --name-only --pretty=format:""')
      .readlines
      .map(&:chomp)
      .reject(&:empty?)
      .select { |file| File.exists? File.expand_path(file, repo_root) }
      .each_with_object(Hash.new 0) { |file, changes| changes[file] += 1 }
      .to_a
      .sort_by(&:last)
      .reverse_each { |file, churn| puts "#{churn.to_s.ljust 4} #{file}" }
  end
end
