require 'sinatra/base'
require "check-taskr"

module CheckTaskr

  class App < Sinatra::Base
    get '/' do
      <<DONE
OK.
DONE
    end

    get '/stats' do
      config = CheckTaskr::JobsConfiguration.instance
      config.results.to_json
    end

  end

end
