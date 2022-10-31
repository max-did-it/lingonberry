module Roarm
  # Relation is common data type
  class Relation
    # @return [Array<Class<Roarm::AbstractModel>>, nil] the array of instances of model or nil
    #   if any records haven't found
    def to_a
    end

    # @return [Class<Roarm::AbstractModel>]
    def first
    end

    # @return [Class<Roarm::AbstractModel>]
    def last
    end
  end
end
