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
      redirect '/stats.html'
    end

    get '/stats' do
      config = CheckTaskr::JobsConfiguration.instance
      config.results.to_json
    end

    get '/lock' do
      config = CheckTaskr::JobsConfiguration.instance
      config.lock
      redirect '/stats.html'
    end

    get '/unlock' do
      config = CheckTaskr::JobsConfiguration.instance
      config.unlock
      redirect '/stats.html'
    end

    get '/stats.html' do
      config = CheckTaskr::JobsConfiguration.instance
      @result = config.results
      @locked = config.locked
      haml <<HAML
%html
  %head
    %title 业务自检
  %body
    %h1.title 自检结果
    - if @locked
      %p 现在不再执行自动检查，自检结果保持为最后一次检查的结果.
      %a{:href => "/unlock"} 重新开始检查
    - else
      %a{:href => "/lock"} 锁定检查结果（发布时避免影响检查结果）
    %br
    %table{:width=>"98%", :border=>1}
      %tr
        %th 名称
        %th IP
        %th 状态码
        %th error_id
        %th 时间戳
        %th msg
      - @result.each do |name, hash|
        - ts = hash[:timestamp] || hash["timestamps"] || 0
        %tr
          %td= name
          %td{:align=>"center"}= hash[:ip] || hash["ip"] || "&nbsp;"
          %td{:align=>"center"}= hash[:stat] || hash["stat"] || "&nbsp;"
          %td{:align=>"center"}= hash[:error_id] || hash["error_id"] || "&nbsp;"
          %td{:align=>"center"}= hash[:timestamp] || hash["timestamps"] || "&nbsp;"
          %td= hash[:msg] || hash["msg"] || "&nbsp;"
HAML
    end
  end

end
