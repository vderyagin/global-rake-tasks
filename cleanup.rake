def cruft
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
    tmp
    .local/share/recently-used.xbel
  ).map { |file| File.expand_path(file, '~') }
end

namespace :cleanup do
  desc 'Get rid of some trash in home directory.'
  task :cruft do
    FileList[cruft].existing.tap do |list|
      if list.empty?
        puts 'no files to delete.'
      else
        list.each(&method(:rm_r))
      end
    end
  end
end
