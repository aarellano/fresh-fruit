require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork

  every(10.seconds, 'read.job') { App.read_status }
  every(10.seconds, 'load.job') { App.load_status }

end