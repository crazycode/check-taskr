# -*- coding: utf-8 -*-
require 'socket'
require 'timeout'

module CheckTaskr

  class JobsConfiguration

    def setup_tcp_port(options)
      SocketAction.setup(options)
    end

    def tcp_port(name, options = {})
      process_hosts(options) do |host|
        action = SocketAction.new(:name => "#{name}-#{host}", :ip => host, :port => options.fetch(:port))
        action.error_code ||= options[:error_code]
        action.error_msg ||= options[:error_msg]

        @actions << action
      end
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
      log = Log4r::Logger['default']
      log.debug "action: ip=#{@ip}, port=#{@port}, name=#{@name}"
      hash = { :stat => 0, :ip => @ip, :msg => "OK", :timestamp => Time.now.to_i, :error_id => @error_code }
      begin
        timeout(5) do
          socket = Socket.new(AF_INET, SOCK_STREAM, 0) #生成新的套接字
          sockaddr = Socket.pack_sockaddr_in(@port, @ip)
          socket.connect(sockaddr)
          log.debug "Port:#{@ip}:#{@port} is Opend!\n"
          socket.close
        end
      rescue Timeout::Error
        hash = {:error_id => @error_code, :stat => 2, :ip => @ip, :msg => "网络访问超时", :timestamp => Time.now.to_i }
        log.error hash.to_json
      rescue Exception => e
        hash = {:error_id => @error_code, :stat => 1, :ip => @ip, :msg => @error_msg || e.to_s, :timestamp => Time.now.to_i }
        log.error hash.to_json
      end
      return hash
    end
  end


end
