# -*- coding: utf-8 -*-
require 'net/http'
require 'json'

module CheckTaskr

  class JobsConfiguration

    def setup_http_json(options)
      HttpJsonAction.setup(options)
    end

    def check_http_json(name, ip, options = {})
      action = HttpJsonAction.new({:name => name, :ip => ip}.merge(options))
      @actions << action
    end
  end

  class HttpJsonAction < JobsAction
    attr_accessor :ip, :port, :path, :method, :post_data, :error_code, :error_msg

    include Socket::Constants

    def initialize(options)
      @name ||= options[:name]
      @ip = options[:ip]
      @port = options[:port] || 80
      @path = options[:path] || "/"
      @method = options[:method] || :get
      @post_data = options[:post_data]
      @error_code = options[:error_code] || @@default_error_code
      @error_msg = options[:error_msg] || @@default_error_msg
    end

    def execute
      puts "http action: ip=#{@ip}, port=#{@port}, name=#{@name}"
      hash = {:stat => 0, :ip => @ip, :msg => "OK" }
      begin
        Net::HTTP.start(@ip, @port) do |http|
          if @method == :get
            response = http.get(@path)
          end
          case @method
          when :get
            response = http.get(@path)
          when :post
            response = http.post(@path, @post_data)
          end
          body = response.body
          puts "body=#{body}"
          hash = JSON.load(body)
          # hash[:timestamp] = Time.now.to_i
        end
      rescue Exception => e
        hash[:error_code] = @error_msg
        hash[:stat] = 2
        hash[:msg] = "HTTP #{@method.to_s} #{@path}出现异常：#{e}"
      end
      hash
    end
  end


end
