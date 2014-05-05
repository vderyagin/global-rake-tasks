desc 'Generate Readme.md'
file 'Readme.md' => Dir['*.rb', '*.rake'] do
  require 'erb'

  command = [].tap do |cmd|
    cmd << 'rake'
    cmd << '--no-system'
    cmd << '--rakelibdir' << __dir__
    cmd << '--tasks'
  end

  TASKS = IO.popen(command)
          .readlines
          .reject { |l| l['rake Readme.md'] }
          .join
          .strip

  readme = <<EOL
# List of tasks: #

```
<%= TASKS %>
```
EOL

  File.open './Readme.md', 'w' do |file|
    file.puts ERB.new(readme).result
  end
end
