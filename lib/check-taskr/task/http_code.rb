# -*- coding: utf-8 -*-
require 'net/http'

module CheckTaskr

  class JobsConfiguration

    def setup_http_returncode(options)
      HttpReturnCodeAction.setup(options)
    end

    def http_returncode(name, options = {})
      process_hosts(options) do |host|
        action = HttpReturnCodeAction.new({:name => name, :ip => host}.merge(options))
        @actions << action
      end
    end
  end

  class HttpReturnCodeAction < JobsAction
    attr_accessor :ip, :port, :path, :method, :post_data, :expect_code, :error_code, :error_msg

    include Socket::Constants

    def initialize(options)
      @name ||= options[:name]
      @ip = options[:ip]
      @port = options[:port] || 80
      @path = options[:path] || "/"
      @method = options[:method] || :get
      @post_data = options[:post_data]
      @expect_code = options[:expect_code] || "200"  #默认期望返回200
      @error_code = options[:error_code] || @@default_error_code
      @error_msg = options[:error_msg] || @@default_error_msg
    end

    def execute
      log = Logger['default']
      log.debug "http action: ip=#{@ip}, port=#{@port}, name=#{@name}"
      hash = {:stat => 0, :ip => @ip, :msg => "OK", :error_id => @error_code }
      begin
        Net::HTTP.start(@ip, @port) do |http|
          http.read_timeout = 5
          if @method == :get
            response = http.get(@path)
          end
          case @method
          when :get
            response = http.get(@path)
          when :post
            response = http.post(@path, @post_data)
          end
          code = response.code
          hash[:timestamp] = Time.now.to_i
          unless @expect_code.eql?(code)
            hash[:stat] = 1
            hash[:msg] = "HTTP #{@method.to_s} #{@path}期望返回#{@expect_code},但返回#{code}"
            log.warn hash.to_json
          end
        end
      rescue Exception => e
        hash[:stat] = 2
        hash[:timestamp] = Time.now.to_i
        hash[:msg] = "HTTP #{@method.to_s} #{@path}出现异常：#{e}"
        log.error hash.to_json
      end
      hash
    end
  end

end
