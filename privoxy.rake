=begin

Rake tasks for toggling privoxy on/off.
Requires privoxy setup to allow such actions

=end

namespace :privoxy do
  require 'net/http'

  PRIVOXY_HOST = '127.0.0.1'
  PRIVOXY_PORT = 8118
  PROXY = Net::HTTP::Proxy PRIVOXY_HOST, PRIVOXY_PORT

  def privoxy(action)
    PROXY.start 'p.p' do |http|
      http.get "/toggle?set=#{action}", 'Referer' => 'http://p.p/toggle'
    end
  end

  desc 'Enable privoxy'
  task :enable do
    privoxy :enable
  end

  desc 'Disable privoxy'
  task :disable do
    privoxy :disable
  end
end
