module Muck
  module ConfigDSL
    class DatabaseDSL

      def initialize(hash)
        @hash = hash
      end

      def name(name)
        @hash[:name] = name
      end

      def hostname(hostname)
        @hash[:hostname] = hostname
      end

      def username(username)
        @hash[:username] = username
      end

      def password(password)
        @hash[:password] = password
      end

    end
  end
end
