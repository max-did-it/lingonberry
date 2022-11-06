# Lingonberry - Object-relational mapper for Redis in Ruby

[![specs](https://github.com/max-did-it/lingonberry/actions/workflows/spec.yml/badge.svg?branch=master)](https://github.com/max-did-it/lingonberry/actions/workflows/spec.yml)


## Install


```bash
gem install lingonberry
```

or in `Gemfile` 

```ruby
gem 'lingonberry'
```

## Example of usage

Short example:


Custom data types
```ruby
class TestType < Lingonberry::Types::Enum
  null true
  keys %i[key1 key2]
end
```

Model definition
```ruby
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

  # Double underscore defines namespace
  # If modules isn't defined schema'll create them itself
  # Example: 
  # model :api__v1__users__client <=> Api::V1::Users::Client
  model :api__user do |m|
    m.primary_key :id
    m.string :full_name
    m.string :email, uniq: true
  end
end

class TestModel < Base
end

TestSchema.define
Api::User.new
#=> #<Api::User:0x000055ba233febd8> id, full_name, email
TestModel.new
#=> #<TestModel:0x000055ba2303a8a8> id, string, array, set, ordered_set, enum1, enum2, float, hash1, hash2, integer, list, timestamp, timestamp_with_index
```

Or direct way

```ruby
class TestModel < Lingonberry::AbstractModel
  include Lingonberry::Types

  primary_key :id
  field :string, String, uniq: true, null: false
  field :array, [TestType], length: {lt: 5}
  field :set, Set, length: {lt: 5}
  field :ordered_set, Set, length: {lt: 5}, sorted: true
  field :enum1, Enum, keys: %i[key1 key2 key3], null: true, numeric_index: true
  field :enum2, Enum, keys: {key1: 1, key2: 2, key3: 5, defualt: 0}, null: false
  field :float, Float, precision: 2, null: true
  field :hash1, Hash, keys: %i[key1 key2 key3 key4]
  field :hash2, Hash
  field :integer, Integer
  field :list, List
  field :timestamp, Timestamp
  field :timestamp_with_index, Timestamp, numeric_index: true
end
```

## DataTypes

  - [AbstractType](#abstracttype)
  - [Numeric](#numeric)
  - [Integer](#integer)
  - [String](#string)
  - [Float](#float)
  - [Timestamp](#timestamp)
  - [Enum](#enum)
  - [Hash](#hash)
  - [Array](#array)
  - [Set](#set)
  - [Stream](#stream)

### AbstractType
Base Interface for Lingonberry Data Types
Implements options `null, serizelier, deserializer, validator, expire, generator`. These options might be given as options for the field.


### Numeric
Primitve for all numeric types. Implements numeric indexing.

### Integer
Primitive data type. Accepts any value which respond on #to_i.
### String
Primitive data type. Accepts any value which respond on #to_s. 
Stored value won't coerced to original data type if it wasn't something other than a string
### Float
Primitive data type. Accepts any value which respond on #to_f.
### Timestamp
Accepts string which can being parsed by `Time.parse string`, ::Time class, ::Float or ::Integer.
Return instance of Time class.
### Enum
### Hash
### Array
### Set
### Stream

## Custom data type

```ruby
# Based on the other Data type
class TestType < Lingonberry::Types::Enum
  null true
  keys(*%i[key1 key2])
end

# Based on AbstractType
class StateType < Lingonberry::Types::AbstractType
  extend Helpers::Types::Options[:length, :keys]

  null false
  length gt: 18, lt: 120
  
  deserializer do |age| 
    "User age is #{age}"
  end
end
```
