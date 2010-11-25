# -*- coding: utf-8 -*-
JobsConfiguration.init(:port => 4899) do |j|
  j.setup_tcp_port :error_code => 10231

  j.check_tcp_port "HudsonServer", "10.241.12.38", 8099

  j.check_tcp_port "NotExistsDB", "10.251.251.38", 18299, { :error_msg => "这一服务没有打开" }

  #j.check_tcp_port "MysqlDB", "10.241.12.38", 3306

  #j.check_tcp_port "NotOpenHOST", "10.241.12.38", 7130

  # j.check_ping "10.20.129.3", { :error_code => 100343 }

  j.check_http_returncode "HudsonWeb", "10.241.12.38", { :port => 8099, :error_code => 909915}
  #j.check_http_returncode "HudsonWeb2", "10.241.12.38", { :port => 80109, :error_code => 909915}

  #j.check_http_result "EsbCheck", "localhost", { :port => 4899, :path => "/", :expect_result => "OK" }
  j.check_http_json "Sujie", "10.241.38.75", :port => 8080, :path => "/admin/msg_admin_check_status", :error_code => 324234

end
