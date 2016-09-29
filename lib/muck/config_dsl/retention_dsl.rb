module Muck
  module ConfigDSL
    class RetentionDSL

      def initialize(hash)
        @hash = hash
      end

      def hourly(hourly)
        @hash[:hourly] = hourly
      end

      def daily(daily)
        @hash[:daily] = daily
      end

      def monthly(monthly)
        @hash[:monthly] = monthly
      end

      def yearly(yearly)
        @hash[:yearly] = yearly
      end

    end
  end
end
