module Muck
  module ConfigDSL
    class StorageDSL

      def initialize(hash)
        @hash = hash
      end

      def path(path)
        @hash[:path] = path
      end

      def keep(keep)
        @hash[:keep] = keep
      end

    end
  end
end
