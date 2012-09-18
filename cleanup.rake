desc 'Get rid of some trash in home directory.'
task :cleanup do
  clean = Rake::FileList.new

  [
    '.emacs.d/image-dired',
    '.emacs.d/url',
    '.rbx',
    '.serverauth.*',
    '.thumbnails',
    '.url',
  ].each do |file|
    clean.add File.expand_path(file, '~')
  end

  clean.existing!

  if clean.empty?
    puts 'no files to delete.'
  else
    clean.each &method(:rm_r)
  end
end
