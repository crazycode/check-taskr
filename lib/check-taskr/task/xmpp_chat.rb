# -*- coding: utf-8 -*-
require 'net/http'
require 'uuid'
require 'xmpp4r'

module CheckTaskr

  class JobsConfiguration

    def setup_xmpp_chat(options)
      HttpReturnCodeAction.setup(options)
    end

    def xmpp_chat(name, options = {})
      process_hosts(options) do |host|
        action = XmppChatAction.new({:name => "#{name}-#{host}", :ip => host}.merge(options))
        @actions << action
      end
    end
  end

  class XmppChatAction < JobsAction
    attr_accessor :ip, :port, :sjid1, :jid1, :password1, :sjid2, :jid2, :password2, :error_code, :error_msg, :client1, :client2, :is_failed

    include Socket::Constants

    def initialize(options)
      @name ||= options[:name]
      @ip = options[:ip]
      @port = options[:port] || 5222
      @sjid1 = options[:jid1]
      @password1 = options[:password1]
      @sjid2 = options[:jid2]
      @password2 = options[:password2]
      @error_code = options[:error_code] || @@default_error_code
      @error_msg = options[:error_msg] || @@default_error_msg

      login1
      login2
    end

    def login1
      @jid1 = Jabber::JID.new("#{@sjid1}/check-taskr")
      if !@client1.nil? && @client1.is_connected?
        @client1.close
      end
      @client1 = Jabber::Client.new(@jid1)
      @client1.connect(@ip, @port)
      @client1.auth(@password1)
      @client1.send(Jabber::Presence.new.set_show(:chat).set_status('check-taskr!'))
    end

    def login2
      @jid2 = Jabber::JID.new("#{@sjid2}/check-taskr")
      if !@client2.nil? && @client2.is_connected?
        @client2.close
      end
      @client2 = Jabber::Client.new(@jid2)
      @client2.add_message_callback do |m|
      if m.type != :error
        @message_body = m.body
      end
    end
      @client2.connect(@ip, @port)
      @client2.auth(@password2)
      @client2.send(Jabber::Presence.new.set_show(:chat).set_status('check-taskr!'))
    end

    def execute
      log = Log4r::Logger['default']
      log.debug "xmpp action: ip=#{@ip}, port=#{@port}, name=#{@name}"
      hash = {:stat => 0, :ip => @ip, :msg => "OK", :error_id => @error_code }
      begin
        unless @client1.is_connected?
          login1
        end

        unless @client2.is_connected?
          login2
        end

        body = UUID.generate
        message = Jabber::Message::new(@jid2, body).set_type(:normal).set_id('1')
        @client1.send(message)

        sleep(0.2)

        hash[:timestamp] = Time.now.to_i
        unless body.eql?(@message_body)
          hash[:stat] = 3
          hash[:msg] = "在0.2秒内没有收到回应"
        end

      rescue Exception => e
        hash[:stat] = 2
        hash[:timestamp] = Time.now.to_i
        hash[:msg] = "XMPP异常：#{e}"
        log.error hash.to_json
      end
      hash
    end
  end

end
