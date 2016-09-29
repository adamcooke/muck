module Muck
  module ConfigDSL
    class SSHDSL

      def initialize(hash)
        @hash = hash
      end

      def port(port)
        @hash[:port] = port
      end

      def key(key)
        @hash[:key] = key
      end

      def username(username)
        @hash[:username] = username
      end

    end
  end
end
