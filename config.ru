require 'rack-livereload'

root=Dir.pwd
use Rack::LiveReload, :no_swf => true
run Rack::Directory.new("#{root}")
