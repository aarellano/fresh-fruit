task :read_status do
	`top -p $(pgrep -d',' -f 'unicorn master') -n 1 -bc > log/apps.log`
end

task load_status: :environment do
	IO.readlines('log/apps.log').drop(7).each do |line|
		next if line.strip.empty?
		line_split = line.split
		App.where(name: line_split[14].split("/")[4]) << AppStatus.new(cpu: line_split[8].to_f, memory: line_split[9].to_f)
	end
end