describe ThemeJuice::Commands::Init do

  before do
    @init = ThemeJuice::Commands::Init
  end

  describe "#execute" do
    it "should successfully initialize" do
      expect(@init.new).to be
    end
  end
end
