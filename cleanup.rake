namespace :cleanup do
  desc 'Get rid of some trash in home directory.'
  task :cruft do
    clean = Rake::FileList.new

    %w(
      .adobe
      .darcs
      .emacs.d/image-dired
      .emacs.d/url
      .fontconfig
      .local/share/Trash
      .macromeda
      .rbx
      .serverauth.*
      .thumbnails
      .url
      Desktop
      Downloads
      tmp
      .local/share/recently-used.xbel
    ).each do |file|
      clean.add File.expand_path(file, '~')
    end

    clean.existing!

    if clean.empty?
      puts 'no files to delete.'
    else
      clean.each(&method(:rm_r))
    end
  end

  desc 'Get rid of *.torrent files in home directory.'
  task :torrents do
    torrents = Rake::FileList.new.add File.expand_path('*.torrent', '~')

    torrents.existing!

    if torrents.empty?
      puts 'no files to delete.'
    else
      torrents.each(&method(:rm_r))
    end
  end
end
