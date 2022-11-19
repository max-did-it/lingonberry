describe "Lingonberry" do
  before do
    c = Redis.new
    c.keys.each do |k|
      c.del k
    end
  end
  let(:test_instance) { create :test_model }

  it "should create the model" do
    expect { create :test_model }.not_to raise_error
  end

  describe "storage namespace" do
    let(:redis_conn) { Redis.new }

    subject { create :test_model }

    before do
    end

    context "primary keys" do
      it "should store primary keys in common model set for primary keys" do
        instance = subject
        redis_key = "lingonberry:testmodel:id"
        expect(redis_conn.exists?(redis_key)).to be_truthy
        expect(redis_conn.smembers(redis_key)).to include(instance.id)
      end

      it "should rename other fields keys if pk changed" do
        redis_key = ->(id) { "lingonberry:testmodel:string:#{id}" }
        instance = subject

        expect(redis_conn.exists?(redis_key.call(instance.id))).to be_truthy
      end
    end

    context "field keys" do
      it "should be composed from model name and primary key" do
      end
    end
  end

  describe "type options" do
    let(:redis_conn) { Redis.new }
    subject { create :test_model }

    context "numeric-index" do
      it "should add member to the sorted set if numeric index enabled" do
        instance = subject
        index_key = "lingonberry:testmodel:enum1"
        expect(redis_conn.exists?(index_key)).to be_truthy
        expect(redis_conn.type(index_key)).to match("zset")

        score = instance.fields[:enum1].type[instance.enum1]
        expect(redis_conn.zrangebyscore(index_key, score, score)).to include(instance.id)
      end

      it do
        instance1 = create :test_model
        instance2 = create :test_model
        index_key = "lingonberry:testmodel:timestamp_with_index"

        time = Time.now
        day = 86400
        instance1.timestamp_with_index = time - day
        instance2.timestamp_with_index = time + 3 * day
        instance1.save!
        instance2.save!

        expect(redis_conn.exists?(index_key)).to be_truthy
        expect(redis_conn.type(index_key)).to match("zset")
        expect(
          redis_conn.zrangebyscore(index_key, (time - day).to_f, (time + 3 * day).to_f)
        ).to match_array([instance1.id, instance2.id])
      end
    end
  end

  describe "Types" do
    context "timestamp" do
      it "should return Time class when set Time" do
        time = Time.now
        test_instance.timestamp = time
        test_instance.save!
        expect(test_instance.timestamp).to be_a(Time)
      end

      it "should return Time class when set string" do
        time = "2022-08-01 18:01:00"
        test_instance.timestamp = time
        test_instance.save!
        expect(test_instance.timestamp).to be_a(Time)
        expect(test_instance.timestamp).to eq(Time.parse(time))
      end
    end

    context "array" do
      it "should raise error when some elements doesn't fit to subType" do
        array = [:key1, :key3]
        test_instance.array = array
        expect { test_instance.save! }.to raise_error(Lingonberry::Errors::InvalidValue)
      end
      it "should store values when all values is correct" do
        array = [:key1, :key2, :key1]
        test_instance.array = array
        test_instance.save!
        expect(test_instance.array).to eq([:key1, :key2, :key1])
      end
    end

    context "set" do
      it "should store an uniq values as set" do
        set = %w[kek lol kek lol]
        test_instance.set = set
        test_instance.save!
        expect(test_instance.set).to match_array(%w[kek lol])
      end
    end

    context "sorted set" do
      it "should store an uniq values as set" do
        set = %w[kek lol kek lol]
        test_instance.sorted_set = set
        test_instance.save!
        expect(test_instance.sorted_set).to eq(%w[kek lol])
      end
    end

    context "enum" do
      it "should raise error when value not from Model#enum#keys" do
        test_instance.enum1 = 1123
        expect { test_instance.save! }.to raise_error(Lingonberry::Errors::InvalidValue)
      end

      it "should accept any type might converted to sym" do
        test_instance.enum1 = "key3"
        expect { test_instance.save! }.not_to raise_error
        expect(test_instance.enum1).to eq(:key3)
      end
    end

    context "float" do
      it "should trim decimal part by precision option" do
        test_instance.float = 1.123
        test_instance.save!
        expect(test_instance.float).to eq(1.12)
      end
    end

    ## TODO develop lazy load for hash
    context "hash" do
      it "should accept a key like instance.hash[key] = value" do
        test_instance.hash1[:key2] = "kek"
        test_instance.save!
        expect(test_instance.hash1[:key2]).to eq("kek")
      end

      it "should raise error when key isn't in keys option if keys options is given" do
        expect { test_instance.hash1[:lol] = "kek" }.to raise_error(Lingonberry::Errors::UnknownKey)
      end

      it "should substitute all hash" do
        hash = {key1: "1", key2: "59"}
        test_instance.hash1 = hash
        expect { test_instance.save! }.not_to raise_error
        expect(test_instance.hash1.to_h).to including(hash)
      end

      it "should accept any keys if keys not given as option for field" do
        hash = {kek: "1", lol: "20"}
        test_instance.hash2 = hash
        expect { test_instance.save! }.not_to raise_error
        expect(test_instance.hash2.to_h).to including(hash)
      end
    end

    context "integer" do
      it "should return integer" do
        value = 123
        test_instance.integer = value
        expect { test_instance.save! }.not_to raise_error
        expect(test_instance.integer).to eq(value)
      end
    end

    context "list" do
      it "should accept array and return array of string" do
        list = [1, 2, 3, :a, :b]
        test_instance.list = list
        expect { test_instance.save! }.not_to raise_error
        expect(test_instance.list).to match_array(["1", "2", "3", "a", "b"])
      end
    end

    context "string" do
      it "should accept any value and return that value coerced to string" do
        value = [1, 2, 3]
        test_instance.string = value
        expect { test_instance.save! }.not_to raise_error
        expect(test_instance.string).to eq(value.to_s)
      end
    end
  end
end
