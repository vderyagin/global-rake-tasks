def cruft
  FileList.new(%w(
    ~/.emacs.d/image-dired
    ~/.emacs.d/url
    ~/.local/share/Trash
    ~/.serverauth.*
    ~/.thumbnails
    ~/.local/share/recently-used.xbel
  ).map(&File.method(:expand_path)))
end

namespace :cleanup do
  desc 'Get rid of some trash in home directory.'
  task :cruft do
    cruft.existing.tap do |list|
      if list.empty?
        warn 'no files to delete.'
      else
        rm_r list
      end
    end
  end
end
