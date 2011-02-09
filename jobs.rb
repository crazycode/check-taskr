# -*- coding: utf-8 -*-
JobsConfiguration.init(:port => 4899) do |check|
  check.log_level DEBUG

  check.setup_tcp_port :error_code => 10231

  check.tcp_port "HudsonServer", :hosts => "10.241.12.38", :port => 8099

  check.tcp_port "NotExistsDB", :hosts => "10.251.251.38", :port => 18299, :error_msg => "这一服务没有打开"

  check.http_returncode "HudsonWeb", :hosts => ["10.241.12.38", "10.241.12.40"],
                  :port => 8099, :error_code => 909915

  check.http_json "Sujie", :hosts => ["10.241.38.75", "10.241.38.22", "10.241.12.38", "10.241.14.35"],
                  :port => 8080, :path => "/admin/msg_admin_check_status", :error_code => 324234

  #  xmpp0004@mim.snda=f18f13ea13af3127ad06f194ebabe602
  #  xmpp0003@mim.snda=778108e5e15a96b6e4becc9b59571414
  #check.xmpp_chat "XMPP", :hosts => "test.mim.iccs.sdo.com", :port => 5222,
  #    :jid1 => "xmpp0004@mim.snda", :password1 => 'f18f13ea13af3127ad06f194ebabe602',
  #    :jid2 => "xmpp0003@mim.snda", :password2 => "778108e5e15a96b6e4becc9b59571414",
  #    :error_code => "32420001", :error_msg => "failed!"
end
