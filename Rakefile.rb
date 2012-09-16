desc 'Generate Readme.md'
file 'Readme.md' => 'Rakefile.rb' do
  require 'erb'

  readme = <<EOL
# List of tasks: #

```
<%= `rake --system --tasks`.strip %>
```
EOL

  File.open './Readme.md', 'w' do |file|
    file.puts ERB.new(readme).result
  end
end
