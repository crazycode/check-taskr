require 'sinatra/base'
require "check-taskr"

class App < Sinatra::Base
  get '/' do
    <<DONE
OK.
DONE
  end

  get '/stats' do
    config = Jobs::JobsConfiguration.instance
    config.results.to_json
  end

end
