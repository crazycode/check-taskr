# -*- coding: utf-8 -*-
require "haml"
require 'sinatra/base'
require "check-taskr"
require "json"

module CheckTaskr

  class App < Sinatra::Base
    before do
      content_type :html, 'charset' => 'utf-8'
    end

    get '/' do
      "OK."
    end

    get '/stats' do
      config = CheckTaskr::JobsConfiguration.instance
      config.results.to_json
    end

    get '/stats.html' do
      config = CheckTaskr::JobsConfiguration.instance
      @result = config.results
      haml <<HAML
%html
  %head
    %title 业务自检
  %body
  %h1.title 自检结果
  %table{:width=>"98%", :border=>1}
    %tr
      %th 名称
      %th IP
      %th 状态码
      %th error_id
      %th msg
    - @result.each do |name, hash|
      %tr
        %td= name
        %td{:align=>"center"}= hash[:ip] || hash["ip"] || "&nbsp;"
        %td{:align=>"center"}= hash[:stat] || hash["stat"] || "&nbsp;"
        %td{:align=>"center"}= hash[:error_id] || hash["error_id"] || "&nbsp;"
        %td= hash[:msg] || hash["msg"] || "&nbsp;"
HAML
    end
  end

end
