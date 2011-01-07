# -*- coding: utf-8 -*-
require "fastthread"
require "check-taskr/base"


Dir[File.join(File.dirname(__FILE__), 'task/*.rb')].sort.each { |lib| require lib }

module CheckTaskr
  class Cli

    def self.execute(filename, options = {})
      logdir = options.delete(:logdir)
      # create a logger named 'mylog' that logs to stdout
      log = Logger.new 'default'
      log.outputters =  Log4r::DateFileOutputter.new('check_log', :dirname => logdir)
      log.level = WARN

      log.debug("load #{filename} file, log on #{logdir} ...")

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
