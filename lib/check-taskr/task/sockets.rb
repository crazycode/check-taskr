require 'socket'

module CheckTaskr

  class JobsConfiguration

    def setup_tcp_port(options)
      SocketAction.setup(options)
    end

    def check_tcp_port(name, ip, port, options = {})
      action = SocketAction.new(:name => name, :ip => ip, :port => port)

      action.error_code ||= options[:error_code]
      action.error_msg ||= options[:error_msg]

      # new 一个action，加到Configuration.configs数组中.
      @actions << action
    end
  end

  class SocketAction < JobsAction
    attr_accessor :ip, :port, :error_code, :error_msg

    include Socket::Constants

    def initialize(options)
      @name = options[:name]
      @ip = options[:ip]
      @port = options[:port]
      @error_code = options[:error_code] || @@default_error_code
      @error_msg = options[:error_msg] || @@default_error_msg
    end

    def execute
      puts "action: ip=#{@ip}, port=#{@port}, name=#{@name}"
      begin
        socket = Socket.new(AF_INET, SOCK_STREAM, 0) #生成新的套接字
        sockaddr = Socket.pack_sockaddr_in(@port, @ip)
        socket.connect(sockaddr)
        # puts "Port:#{@ip}:#{@port} is Opend!\n"
        socket.close
        hash = { :stat => 0, :ip => @ip, :msg => "OK", :timestamp => Time.now.to_i }
        return hash
      rescue Exception => e
        # puts "connet fail:#{e}"
        hash = {:error_id => @error_code, :stat => 1, :ip => @ip, :msg => @error_msg || e.to_s, :timestamp => Time.now.to_i }
        return hash
      end
    end
  end


end
