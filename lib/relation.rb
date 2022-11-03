module Lingonberry
  # Relation is common data type
  class Relation
    # @return [Array<Class<Lingonberry::AbstractModel>>, nil] the array of instances of model or nil
    #   if any records haven't found
    def to_a
    end

    # @return [Class<Lingonberry::AbstractModel>]
    def first
    end

    # @return [Class<Lingonberry::AbstractModel>]
    def last
    end
  end
end
