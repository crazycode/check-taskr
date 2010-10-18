# -*- coding: utf-8 -*-
require 'singleton'

module Jobs

  class JobsAction
    attr_accessor :name

    @@default_error_code = nil

    def self.setup(options={})
      puts "hhh=#{options}"
      @@default_error_code = options[:error_code]
    end
  end

  class JobsConfiguration

    include Singleton

    attr_accessor :sleep_time, :results
    attr_reader :load_paths, :actions

    def initialize
      @actions = []
      @sleep_time = 5
      @results = Hash.new
    end

    def add_item(item)
      if @items.nil?
        @items = Array.new
      end
      @items.add(item)
    end

    def self.init(sleep_time = 8)
      _instance = self.instance
      _instance.sleep_time = sleep_time
      if block_given?
        yield _instance
      end
    end

    def execute_all
      results = Hash.new
      @actions.each do |action|
        hash = action.execute
        unless hash.nil?
          results[action.name] = hash
        end
      end
      @results.clear
      @results = results
    end

    def load_from_file(file, name=nil)
      file = find_file_in_load_path(file) unless File.file?(file)
      string = File.read(file)
      instance_eval(string, name || "<eval>")
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
