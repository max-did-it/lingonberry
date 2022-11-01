module Roarm
  # Namespace for all gem errors
  module Errors
    # Used to raise a error when method called in abstract class
    class AbstractClass < StandardError; end

    # Used to raise a error when noone argument is given
    class NoArgsGiven < StandardError; end
  end
end
