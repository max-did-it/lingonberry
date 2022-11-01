describe "Roarm" do
  it "should create the model" do
    expect { create :test_model }.not_to raise_error
  end

  context "timestamp" do
    let(:test_instance) { create :test_model }
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
    let(:test_instance) { create :test_model }
    it "should raise error when some elements doesn't fit to subType" do
      array = [:key1, :key3]
      test_instance.array = array
      expect { test_instance.save! }.to raise_error(Roarm::Errors::InvalidValue)
    end
    it "should store values when all values is correct" do
      array = [:key1, :key2, :key1]
      test_instance.array = array
      test_instance.save!
      expect(test_instance.array).to eq([:key1, :key2, :key1])
    end
  end
end
