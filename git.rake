namespace :git do
  desc 'List files in git repository with number of changes.'
  task :churn do
    IO.popen('git log --name-only --pretty=format:""')
      .readlines
      .map(&:chomp)
      .reject(&:empty?)
      .each_with_object(Hash.new 0) do |file, changes|
      changes[file] += 1
    end.to_a.sort_by(&:last).reverse_each do |file, churn|
      puts "#{churn.to_s.ljust 4} #{file}"
    end
  end
end
