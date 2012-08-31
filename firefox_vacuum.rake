desc 'VACUUM all the sqlite database files used by firefox'
task :firefox_vacuum do
  wildcards = [
    '~/.mozilla/firefox/**/*.sqlite',
    '~/.thunderbird/**/*.sqlite'
  ].map &(File.method :expand_path)

  wildcards.each do |wildcard|
    Dir.glob wildcard do |db|
      IO.popen ['sqlite3', db], 'w' do |process|
        puts "vacuuming #{db}"
        process.write 'VACUUM;'
        process.close_write
      end
    end
  end
end
