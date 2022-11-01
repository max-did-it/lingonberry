describe "Roarm" do
  it "should create the model" do
    expect { create :user }.not_to raise_error
  end

  context 'when given timestamp' do
    let(:user) { create :user }
    it 'should return Time class' do
      user.timestamp = Time.now
      user.save!
      expect(user.timestamp).to be(Time)
    end
  end
end
