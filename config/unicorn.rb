def development?
  ENV["RACK_ENV"] == 'development'
end

APP = "fulcrum"
APP_DIR = development? ? File.expand_path("..",File.dirname(__FILE__)) : "/var/www/apps/#{APP}"

CURRENT_DIR = development? ? APP_DIR : "#{APP_DIR}/current"

worker_processes 1
working_directory CURRENT_DIR

# This loads the application in the master process before forking
# worker processes
# Read more about it here:
# http://unicorn.bogomips.org/Unicorn/Configurator.html
#preload_app true
timeout 30

# This is where we specify the socket.
# We will point the upstream Nginx module to this socket later on
listen ( development? ? "127.0.0.1:8080" : "#{CURRENT_DIR}/tmp/sockets/unicorn.sock" ), :backlog => 64

pid "#{CURRENT_DIR}/tmp/pids/unicorn.pid"

# Set the path of the log files inside the log folder of the testapp
stderr_path "#{CURRENT_DIR}/log/unicorn.stderr.log"
stdout_path "#{CURRENT_DIR}/log/unicorn.stdout.log"


# combine REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true

before_fork do |server, worker|

  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  old_pid = "#{CURRENT_DIR}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
