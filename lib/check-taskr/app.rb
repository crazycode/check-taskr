# -*- coding: utf-8 -*-
require 'sinatra/base'
require "check-taskr"

module CheckTaskr

  class App < Sinatra::Base
    get '/' do
      "OK."
    end

    get '/stats' do
      config = CheckTaskr::JobsConfiguration.instance
      config.results.to_json
    end

  end

end
