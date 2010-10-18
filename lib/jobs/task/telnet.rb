require 'socket'

module Jobs

  class JobsConfiguration
    def check_telnet(name, ip, port, options = {})
      action = TelnetAction.new(name)

      action.ip = ip
      action.port = port

      action.error_code ||= options[:error_code]

      # new 一个action，加到Configuration.configs数组中.
      @actions << action
    end
  end

  class TelnetAction < JobsAction
    attr_accessor :ip, :port, :error_code, :error_msg

    include Socket::Constants

    def initialize(name = nil)
      @name = name
      @error_code = @@default_error_code
      puts "error@code=#{@error_code}"
    end

    def execute
      puts "action: ip=#{@ip}, port=#{@port}, name=#{@name}"
      begin
        socket = Socket.new(AF_INET, SOCK_STREAM, 0) #生成新的套接字
        sockaddr = Socket.pack_sockaddr_in(@port, @ip)
        socket.connect(sockaddr)
        puts "Port:#{@ip}:#{@port} is Opend!\n"
        socket.close
      rescue Exception => e
        puts "connet fail:#{e}"
        hash = {:error_id => @error_code, :stat => 1, :ip => @ip, :msg => e.to_s, :timestamp => Time.now.to_i }
        return hash
      end
      # 返回一个hash
      return nil
    end
  end


end
