class Base < Roarm::AbstractModel
  include Roarm::Types
end

class TestType < Roarm::Types::Enum
  null true
  keys(*%i[key1 key2])
end

class TestModel < Base
  primary_key :primary_key, UUID
  field :string, String, uniq: true, null: false
  field :array, [TestType], length: {lt: 5}
  field :enum1, Enum, keys: %i[key1 key2 key3], store_as_string: true, null: true
  field :enum2, Enum, keys: {key1: 1, key2: 2, key3: 5, defualt: 0}, null: false
  field :float, Float, precision: 2, null: true
  field :hash, Hash, keys: %i[key1 key2 key3 key4]
  field :integer, Integer
  field :list, List
  field :timestamp, Timestamp
  field :uuid, UUID
end

FactoryBot.define do
  factory :test_model, class: TestModel do
    string { "John" }
    array { [:key1, :key2] }
    enum1 { :key3 }
    enum2 { :key1 }
    float { 1.3 }
    hash { {key1: :lol} }
    integer { 123 }
    list { [1, 2, "asd", "0.3"] }
    timestamp { Time.now }
    uuid { SecureRandom.uuid }
  end
end
