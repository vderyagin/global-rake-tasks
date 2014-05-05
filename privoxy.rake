=begin

Rake tasks for toggling privoxy on/off.

Requires "enable-remote-toggle" option to be enabled in privoxy configuration.

=end

def privoxy(action)
  require 'net/http'

  Net::HTTP::Proxy('127.0.0.1', 8118).start 'p.p' do |http|
    http.get "/toggle?set=#{action}", 'Referer' => 'http://p.p/toggle'
  end
end

namespace :privoxy do
  desc 'Enable privoxy.'
  task :enable do
    privoxy :enable
  end

  desc 'Disable privoxy.'
  task :disable do
    privoxy :disable
  end
end
