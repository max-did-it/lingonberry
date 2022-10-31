module Roarm
  module Helpers
    module Types
      class << self
        # When incldued in type allow to use construction Type[] to declare field with type array of Types
        def []
          Types::Array.new(self)
        end
      end
    end
  end
end
