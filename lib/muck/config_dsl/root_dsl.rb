require 'muck/config_dsl/server_dsl'
require 'muck/server'
module Muck
  module ConfigDSL
    class RootDSL

      def initialize(config)
        @config = config
      end

      def server(&block)
        hash = Hash.new
        dsl = ServerDSL.new(hash)
        dsl.instance_eval(&block)
        @config.servers << Server.new(@config, hash)
      end

      def defaults(&block)
        dsl = ServerDSL.new(@config.defaults)
        dsl.instance_eval(&block)
      end

    end
  end
end
