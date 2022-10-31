class Base < Roarm::AbstractModel
  include Roarm::Types
end

class TestType < Roarm::Types::Enum
  uniq false
  null true
  keys %i[key1 key2]
end

class TestModel < Base
  pk :primary_key, UUID
  field :string, String, uniq: true, null: false
  field :array, Array(TestType), size: {lt: 5}
  field :enum1, Enum, keys: %i[key1 key2 key3], store_as_string: true, null: true
  field :enum2, Enum, keys: {key1: 1, key2: 2, key3: 5, defualt: 0}, null: false
  field :float, precision: 2, null: true
  field :hash, Hash, keys: %i[key1 key2 key3 key4]
  field :integer, Integer
  field :list, List
  field :timestamp, Timestamp
  field :uuid, UUID
end

FactoryBot.define do
  factory :user, class: TestModel do
    first_name { "John" }
    last_name { "Doe" }
    admin { false }
  end
end
