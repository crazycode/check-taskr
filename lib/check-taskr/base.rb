# -*- coding: utf-8 -*-
require 'singleton'

module CheckTaskr

  class JobsAction
    attr_accessor :name

    @@default_error_code = nil
    @@default_error_msg = nil
    def self.setup(options={})
      @@default_error_code = options[:default_error_code]
      @@default_error_msg = options[:default_error_msg]
    end
  end

  class JobsConfiguration

    include Singleton
    include Log4r

    attr_accessor :sleep_time, :results, :listen_port, :locked
    attr_reader :load_paths, :actions

    def initialize
      @actions = []
      @sleep_time = 8
      @results = Hash.new
      @listen_port = 4567
      @locked = false
    end

    def add_item(item)
      if @items.nil?
        @items = Array.new
      end
      @items.add(item)
    end

    def lock
      @locked = true
    end

    def unlock
      @locked = false
    end

    def self.init(options = {})
      _instance = self.instance
      _instance.sleep_time = options[:sleep_time] || 8
      _instance.listen_port = options[:port] || 4567
      if block_given?
        yield _instance
      end
    end

    def execute_all
      log = Log4r::Logger['default']
      return if @locked
      results = Hash.new
      had_error = false

      fail_actions = run_actions(@actions, results)

      # 如果有失败，过0.1秒后重试失败的
      if fail_actions.size > 0
        sleep(0.1)
        fail_actions2 = run_actions(fail_actions, results)
        if fail_actions2.size > 0
          # 还失败的话，过1秒后重新试一次
          sleep(1)
          run_actions(fail_actions2, results)
        end
      end
      @results.clear
      @results = results
    end

    def run_actions(actions, results)
      fail_actions = []
      log = Log4r::Logger['default']
      actions.each do |action|
        hash = action.execute
        unless hash.nil?
          if hash["ip"].nil? && hash[:ip].nil?
            hash.each do |k, v|
              unless (v["ip"].nil? && v[:ip].nil?)
                results["#{action.name}_#{k}"] = v
              end
            end
          else
            results[action.name] = hash
          end
          state_code = hash[:stat] || hash['stat']
          if !"0".eql?(state_code) && !0.eql?(state_code)
            log.error "#{Time.now}:#{hash.to_json}"
            fail_actions << action
          end
        end
      end
      fail_actions
    end

    def load_from_file(file, name=nil)
      file = find_file_in_load_path(file) unless File.file?(file)
      string = File.read(file)
      instance_eval(string, name || "<eval>")
    end


    # set log level
    def log_level(level)
      log = Log4r::Logger['default']
      log.level = level
    end

    # process hosts from options
    def process_hosts(options)
      log = Log4r::Logger['default']
      hosts = options.delete(:hosts)
      if block_given?
        if hosts.nil?
          throw Exception.new("Must include :hosts option")
        end
        if hosts.class.eql?(String)
          yield hosts
        else
          hosts.each do |host|
            yield host
          end
        end
      end
    end

    private

    def find_file_in_load_path(file)
      [".", File.expand_path(File.join(File.dirname(__FILE__), "../recipes"))].each do |path|
        ["", ".rb"].each do |ext|
          name = File.join(path, "#{file}#{ext}")
          return name if File.file?(name)
        end
      end

      raise LoadError, "no such file to load -- #{file}"
    end

  end

end
