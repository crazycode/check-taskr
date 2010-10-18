require "fastthread"
require "jobs/base"

Dir[File.join(File.dirname(__FILE__), 'jobs/task/*.rb')].sort.each { |lib| require lib }

class Cli

  def self.execute(options = {})

    config = Jobs::JobsConfiguration.instance
    config.load_from_file("jobs")

    t = Thread.new do
      while true do
        hash = config.execute_all
        sleep(config.sleep_time)
      end
    end

  end


end
