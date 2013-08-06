task read_status: do
	command "top -p $(pgrep -d',' -f 'unicorn master') -n 1 -b > log/apps.log"
end

task load_status: :environment do
	IO.readlines('apps.log').drop(7).each do |line|
		next if line.strip.empty?
		App.create(name: line.split[14].split("/")[4])
	end
end