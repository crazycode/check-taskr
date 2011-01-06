# -*- coding: utf-8 -*-
require 'net/http'
require 'json'

module CheckTaskr

  class JobsConfiguration

    def setup_http_json(options)
      HttpJsonAction.setup(options)
    end

    def http_json(name, options = {})
      process_hosts(options) do |host|
        action = HttpJsonAction.new({:name => name, :ip => host}.merge(options))
        @actions << actions
      end
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
      log = Logger['default']
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
          body = response.body
          puts "body=#{body}"
          hash = JSON.load(body)
          # hash[:timestamp] = Time.now.to_i
          #if hash["stat"] && hash["stat"].to_i > 0
          hash.each do |k, v|
            v[:error_id] = @error_code
            v[:ip] = @ip
          end
          #end
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
