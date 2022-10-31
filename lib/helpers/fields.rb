module Roarm
  module Helpers
    module Fields
      def direct_call_protection
        raise DirectMethodCall, "Direct call "
      end

      class DirectMethodCall < StandardError; end
    end
  end
end
