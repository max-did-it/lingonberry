class Base < Lingonberry::AbstractModel
  include Lingonberry::Types
end

module Test
  class MyType < Lingonberry::Types::Enum
    null true
    keys %i[key1 key2]
  end
end

class TestSchema < Lingonberry::Schema
  custom_types ::Test
  model :test_model do |m|
    m.primary_key :id
    m.string :string, uniq: true, null: false
    m.test__my_type :array, length: {lt: 5}, array: true
    m.set :set, length: {lt: 5}
    m.set :ordered_set, length: {lt: 5}, sorted: true
    m.enum :enum1, keys: %i[key1 key2 key3], null: true, numeric_index: true
    m.enum :enum2, keys: {key1: 1, key2: 2, key3: 5, defualt: 0}, null: false
    m.float :float, precision: 2, null: true
    m.hash :hash1, keys: %i[key1 key2 key3 key4]
    m.hash :hash2
    m.integer :integer
    m.list :list
    m.timestamp :timestamp
    m.timestamp :timestamp_with_index, numeric_index: true
  end

  model :api__user do |m|
    m.primary_key :id
    m.string :full_name
    m.string :email, uniq: true
  end
end

class TestModel < Base
end

TestSchema.define

FactoryBot.define do
  factory :test_model, class: TestModel do
    string { "John" }
    array { [:key1, :key2] }
    enum1 { :key3 }
    enum2 { :key1 }
    float { 1.3 }
    hash1 { {key1: :lol} }
    integer { 123 }
    list { [1, 2, "asd", "0.3"] }
    timestamp { Time.now }
    timestamp_with_index { Time.now }
  end
end
