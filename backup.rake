namespace :backup do
  def srm(*files)
    sh 'srm', *files
  end

  def srm_r(*files)
    sh 'srm', '--recursive', *files
  end

  def gpg_encrypt_symmetrically(file)
    sh 'gpg', '--symmetric', '--force-mdc', file
    srm file
  end

  def exit_if_file_exists(file)
    if File.exists? file
      puts "file #{file} already exists."
      exit 1
    end
  end

  def create_zip_archive(archive, *files)
    sh 'zip', '--junk-paths', archive , *files
  end

  desc 'Make encrypted backup of gpg keys.'
  task :gpg_keys do
    archive_file = 'gpg_keys.zip'

    sh 'gpg --export vderyagin@gmail.com > public_key.txt'
    sh 'gpg --export-secret-key vderyagin@gmail.com > secret_key.txt'

    create_zip_archive archive_file, 'public_key.txt', 'secret_key.txt'
    srm 'public_key.txt', 'secret_key.txt'
    gpg_encrypt_symmetrically archive_file
  end

  desc 'Make encrypted backup of gmail data.'
  task :gmail do
    imap_backup = File.expand_path '~/vderyagin@gmail.com'
    cd File.dirname imap_backup
    archive_file = 'gmail.zip'
    sh 'offlineimap'
    sh 'zip', '--recurse-paths', archive_file, File.basename(imap_backup)
    srm_r imap_backup
    gpg_encrypt_symmetrically archive_file
  end

  desc 'Make encrypted backup of encrypted org files.'
  task :org do
    org_files = Dir[File.expand_path '~/org/**/*.org.gpg']
    archive_file = 'org.zip'

    create_zip_archive archive_file, *org_files
    gpg_encrypt_symmetrically archive_file
  end

  namespace :ssh do
    def public_keys
      Dir[File.expand_path '~/.ssh/*.pub']
    end

    def private_keys
      public_keys
        .map    { |pub| pub.chomp '.pub' }
        .select { |key| File.exists? key }
    end

    desc 'Make encrypted backup of public SSH keys.'
    task :public do
      archive_file = 'public_ssh_keys.zip'
      create_zip_archive archive_file, *public_keys
      gpg_encrypt_symmetrically archive_file
    end

    desc 'Make encrypted backup of all SSH keys.'
    task :all do
      archive_file = 'all_ssh_keys.zip'
      create_zip_archive archive_file, *(public_keys | private_keys)
      gpg_encrypt_symmetrically archive_file
    end
  end

  task ssh: 'ssh:all'
end
