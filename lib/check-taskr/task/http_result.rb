# -*- coding: utf-8 -*-
require 'net/http'

module CheckTaskr

  class JobsConfiguration

    def setup_http_result(options)
      HttpResultAction.setup(options)
    end

    def check_http_result(name, options = {})
      process_hosts(options) do |host|
        action = HttpResultAction.new({:name => "#{name}-#{host}", :ip => host}.merge(options))
        @actions << action
      end
    end
  end

  class HttpResultAction < JobsAction
    attr_accessor :ip, :port, :path, :method, :post_data, :expect_result, :error_code, :error_msg

    include Socket::Constants

    def initialize(options)
      @name ||= options[:name]
      @ip = options[:ip]
      @port = options[:port] || 80
      @path = options[:path] || "/"
      @method = options[:method] || :get
      @post_data = options[:post_data]
      @expect_result = options[:expect_result] || "ok"  #默认期望返回200
      @error_code = options[:error_code] || @@default_error_code
      @error_msg = options[:error_msg] || @@default_error_msg
    end

    def execute
      log = Log4r::Logger['default']
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
          result = response.body
          hash[:timestamp] = Time.now.to_i
          unless result.include?(@expect_result)
            hash[:stat] = 1
            hash[:msg] = "HTTP #{@method.to_s} #{@path}期望返回值包含\"#{@expect_result}\",但返回\"#{result}\""
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
