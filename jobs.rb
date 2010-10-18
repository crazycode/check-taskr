
Jobs::TelnetAction.setup(:error_code => 100323)

JobsConfiguration.init do |j|
  j.check_telnet "HudsonServer", "10.241.12.38", 8099
  j.check_telnet "NotExistsDB", "10.251.251.38", 18299
  j.check_telnet "MysqlDB", "10.251.12.38", 3306
  j.check_telnet "NotOpenHOST", "10.241.12.38", 7130
  # j.check_ping "10.20.129.3", { :error_code => 100343 }
end
