require "fastthread"
require "check-taskr/base"

Dir[File.join(File.dirname(__FILE__), 'task/*.rb')].sort.each { |lib| require lib }

module CheckTaskr
  class Cli

    def self.execute(options = {})

      config = CheckTaskr::JobsConfiguration.instance
      config.load_from_file("jobs")

      t = Thread.new do
        while true do
          hash = config.execute_all
          sleep(config.sleep_time)
        end
      end

    end

  end

end
