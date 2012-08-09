desc 'Locate lines of code, that are too long.'
task :longlines do
  pattern         = ENV['PATTERN'] || '**/*.rb'
  length_limit    = ENV['LENGTH_LIMIT'] || 80
  ignore_comments = (ENV['IGNORE_COMMENTS'] == 'false' ? false : true)

  Dir.glob pattern do |file|
    File.foreach(file).with_index(1) do |line, index|
      if file.end_with?('.rb') && ignore_comments
        next if line =~ /^\s*#/
        next if (line =~ /^=begin\s*/)..(line =~ /^=end\s*/)
      end

      length = line.chomp.length

      if length > length_limit
        warn "Line too long: #{length} characters (#{file}:#{index})"
      end
    end
  end
end
