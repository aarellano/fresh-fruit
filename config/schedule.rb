set :output, "log/cron.log"
set :environment
every 1.minute do
	rake "read_status"
	rake "load_status"
end