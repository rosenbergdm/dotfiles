require 'rubygems'
require 'wirble'
Wirble.init
Wirble.colorize

require 'bond'
Bond.start :yard_gems=>%w{yard}


Bond.load_yard_gems 'yard'

