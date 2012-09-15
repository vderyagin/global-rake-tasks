DROPBOX_PUBLIC_DIRECTORY = File.expand_path '~/misc/Dropbox/Public'
SCREENSHOTS_DIRECTORY = File.expand_path 'screenshots', DROPBOX_PUBLIC_DIRECTORY

def screenshot_name
  @screenshot_name ||= Time.now.strftime 'screenshot_%Y-%m-%d_%H-%M-%S.png'
end

def screenshot_url
  IO.popen(['dropbox-cli', 'puburl', screenshot_name]).read
end

def put_in_clipboard(text)
  IO.popen ['xclip', '-selection', 'clipboard'], 'w' do |process|
    process.write text
    process.close_write
  end
end

def take_screenshot
  sh 'scrot', screenshot_name
end

desc 'Take screenshot, share it on dropbox.com and put link to it in clipboard.'
task :share_screenshot do
  mkdir SCREENSHOTS_DIRECTORY unless File.exists? SCREENSHOTS_DIRECTORY
  cd SCREENSHOTS_DIRECTORY

  take_screenshot
  put_in_clipboard screenshot_url
end
