set :output, "log/cron.log"
every 1.minute do
	rake "read_status"
	rake "load_status"
end