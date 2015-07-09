describe ThemeJuice::HashHelper do

  before :each do
    @hash = {
      "one" => "1",
      "two" => {
        "three" => "3"
      }
    }
  end

  describe "#symbolize_keys" do

    it "should symbolize hash keys 1 level deep" do
      expect(@hash.symbolize_keys).to eq({
        :one => "1",
        :two => {
          "three" => "3"
        }
      })
    end
  end

  describe "#to_ostruct" do

    it "should cast hash to open struct" do
      expect(@hash.to_ostruct).to be_an OpenStruct
    end

    it "should allow hash to be traversed via method calls" do
      expect(@hash.to_ostruct.two.three).to eq "3"
    end

    it "should not raise error for valid keys" do
      expect { @hash.two }.to_not raise_error
    end

    it "should raise error for invalid keys" do
      expect { @hash.some_random_key }.to raise_error NoMethodError
    end
  end
end
