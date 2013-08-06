class App < ActiveRecord::Base
	belongs_to :host
	has_many :app_statuses
end
