# -*- coding: utf-8 -*-
JobsConfiguration.init(:port => 4899) do |check|
  check.log_level WARN

  check.setup_tcp_port :error_code => 10231

  check.tcp_port "HudsonServer", :hosts => "10.241.12.38", :port => 8099

  check.tcp_port "NotExistsDB", :hosts => "10.251.251.38", :port => 18299, :error_msg => "这一服务没有打开"

  check.http_returncode "HudsonWeb", :hosts => ["10.241.12.38", "10.241.12.40"],
                 :port => 8099, :error_code => 909915

  check.http_json "Sujie", :hosts => ["10.241.38.75", "10.241.38.22", "10.241.12.38", "10.241.14.35"],
                 :port => 8080, :path => "/admin/msg_admin_check_status", :error_code => 324234

end
