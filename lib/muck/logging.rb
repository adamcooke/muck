require 'logger'

module Muck

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  module Logging

    def logger
      Muck.logger
    end

    def log(text)
      logger.info(text)
    end

  end
end
