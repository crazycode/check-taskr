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

    attr_accessor :sleep_time, :results, :listen_port, :locked
    attr_reader :load_paths, :actions

    def initialize
      @actions = []
      @sleep_time = 5
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
      return if @locked
      log = Logger['default']

      results = Hash.new
      had_error = false
      @actions.each do |action|
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
          end
        end
      end
      @results.clear
      @results = results
      log.debug "#{Time.now} result: ================================\n#{results.to_json}"
    end

    def load_from_file(file, name=nil)
      file = find_file_in_load_path(file) unless File.file?(file)
      string = File.read(file)
      instance_eval(string, name || "<eval>")
    end


    # set log level
    def log_level(level)
      log = Logger['default']
      log.level = level
    end

    # process hosts from options
    def process_hosts(options)
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
