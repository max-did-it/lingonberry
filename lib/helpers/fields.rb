module Lingonberry
  module Helpers
    module Fields
      def direct_call_protection
        raise Errors::DirectMethodCall, "Direct call "
      end
    end
  end
end
