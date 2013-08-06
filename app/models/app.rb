class App < ActiveRecord::Base
	belongs_to :host
	has_many :app_statuses

	def self.read_status
		`top -p $(pgrep -d',' -f '^unicorn master') -n 1 -bc > "#{::Rails.root.join('tmp', 'apps.log')}"`
	end

	def self.load_status
		IO.readlines("#{::Rails.root.join('tmp', 'apps.log')}").drop(7).each do |line|
			next if line.strip.empty?
			line_split = line.split
			app_name = line_split[14].split("/")[4]
			if (!app_name.nil? && (app = App.find_by(name: line_split[14].split("/")[4]))).nil?
				app = App.create(name: app_name)
			end
			app << AppStatus.new(cpu: line_split[8].to_f, memory: line_split[9].to_f)
		end
	end
end