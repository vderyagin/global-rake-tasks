namespace :backup do
  EMAIL = 'vderyagin@gmail.com'
  ARCHIVE = File.expand_path '~/encrypted.zip'

  COMMANDS = {
    'public_key.txt'  => ['gpg', '--export', EMAIL],
    'private_key.txt' => ['gpg', '--export-secret-key', EMAIL],
  }

  FILES = [
    '~/org/google-backup-codes.org.gpg',
    '~/org/passwd.org.gpg',
    '~/org/phones.org.gpg',
    '~/.ssh/id_rsa',
    '~/.ssh/id_rsa.pub'
  ].map &(File.method :expand_path)

  def gpg_encrypt_symmetrically(file)
    system 'gpg', '--symmetric', file
    rm file
  end

  def check_if_file_exists(file)
    if File.exists? file
      puts "file #{file} already exists."
      exit 1
    end
  end

  desc 'Make archive of backup files and encrypt it.'
  task :encrypt do
    check_if_file_exists ARCHIVE

    require 'zip/zip'

    Zip::ZipFile.open ARCHIVE, Zip::ZipFile::CREATE do |zipfile|
      zipfile.mkdir 'encrypted'

      COMMANDS.each do |name, command|
        zipfile.get_output_stream File.join('encrypted', name) do |stream|
          stream.puts IO.popen(command).read
        end
      end

      FILES.each do |file|
        zipfile.get_output_stream File.join('encrypted', File.basename(file)) do |stream|
          stream.puts File.read file
        end
      end
    end

    gpg_encrypt_symmetrically ARCHIVE
  end
end
