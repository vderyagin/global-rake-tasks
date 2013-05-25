desc 'VACUUM all the sqlite database files used by firefox and thunderbird.'
task :sqlite_vacuum do
  wildcards = %w(
    ~/.mozilla/firefox/**/*.sqlite
    ~/.thunderbird/**/*.sqlite
  ).map(&(File.method :expand_path))

  wildcards.each do |wildcard|
    Dir.glob wildcard do |db|
      puts "vacuuming #{db}"
      IO.popen ['sqlite3', db], 'w' do |process|
        process.write 'VACUUM;'
        process.close_write
      end
    end
  end
end
