DROPBOX_PUBLIC_DIR = File.expand_path '~/Dropbox/Public'
SHOTS_DIR = File.expand_path 'screenshots', DROPBOX_PUBLIC_DIR

def screenshot_name
  @screenshot_name ||= Time.now.strftime 'screenshot_%Y-%m-%d_%H-%M-%S.png'
end

def screenshot_url
  IO.popen(['dropbox-cli', 'puburl', screenshot_name]).read
end

def put_in_clipboard(text)
  IO.popen %w(xclip -selection clipboard), 'w' do |process|
    process.write text
    process.close_write
  end
end

def take_screenshot
  sh 'scrot', screenshot_name
end

desc 'Take screenshot, share it on dropbox.com and put url in clipboard.'
task :share_screenshot do
  mkdir SHOTS_DIR unless File.exist?(SHOTS_DIR)
  cd SHOTS_DIR

  take_screenshot
  put_in_clipboard screenshot_url
end
