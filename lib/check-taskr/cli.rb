# -*- coding: utf-8 -*-
require "fastthread"
require "check-taskr/base"

Dir[File.join(File.dirname(__FILE__), 'task/*.rb')].sort.each { |lib| require lib }

module CheckTaskr
  include Log4r

  class Cli

    def self.execute(filename, options = {})
      logdir = options.delete(:logdir)
      # create a logger named 'mylog' that logs to stdout

      config = CheckTaskr::JobsConfiguration.instance
      config.load_from_file(filename)

      t = Thread.new do
        while true do
          hash = config.execute_all
          sleep(config.sleep_time)
        end
      end

    end

  end

end
