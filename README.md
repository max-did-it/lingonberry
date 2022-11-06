# Lingonberry - Object-relational mapper for Redis in Ruby

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

```ruby
class BaseModel < Lingonberry::AbstractModel
  include Lingonberry::Types
end

class TestType < Lingonberry::Types::Enum
  null true
  keys(*%i[key1 key2])
end

class TestModel < Base
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
  field :uuid, UUID
end
```

## DataTypes

  - [Integer](#integer)
  - [String](#string)
  - [Float](#float)
  - [Timestamp](#timestamp)
  - [Enum](#enum)
  - [Hash](#hash)
  - [Array](#array)
  - [Set](#set)
  - [Stream](#stream)

### Integer
Primitive data type. Accepts any value which respond on #to_i.
### String
Primitive data type. Accepts any value which respond on #to_s. 
Stored value won't coerced to original data type if it wasn't something other than a string
### Float
Primitive data type. Accepts any value which respond on #to_i.
### Timestamp
Accepts string which can being parsed by `Time.parse string`, Time class, or integer.
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
