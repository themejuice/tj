describe ThemeJuice::HashHelper do

  before do
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

    it "should cast hash to open struct 1 level deep" do
      @hash.to_ostruct.each do |key, value|
        expect(key).to be_an OpenStruct

        key.each do |k, v|
          expect(k).not_to be_an OpenStruct
        end
      end
    end

    it "should recursively cast hash to open struct" do
      @hash.to_ostruct(:recursive => true).each do |key, value|
        expect(key).to be_an OpenStruct

        key.each do |k, v|
          expect(k).to be_an OpenStruct
        end
      end
    end

    it "should allow hash to be traversed via method calls" do
      expect(@hash.to_ostruct.two.three).to eq "3"
    end

    it "should not raise error for valid keys" do
      expect { @hash.two }.to_not raise_error
    end

    it "should raise error for invalid keys" do
      expect { @hash.four }.to raise_error NoMethodError
    end
  end
end
