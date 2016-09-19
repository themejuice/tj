describe ThemeJuice::Migration do

  before do
    allow(ThemeJuice::Env).to receive(:trace).and_return true
  end

  before :each do
    @task = ThemeJuice::Migration.new
  end

  describe "#execute" do
    it "should raise not implemented error" do
      expect(stdout).to receive(:print).with kind_of String
      expect { @task.execute }.to raise_error NotImplementedError
    end
  end

  describe "#unexecute" do
    it "should raise not implemented error" do
      expect(stdout).to receive(:print).with kind_of String
      expect { @task.unexecute }.to raise_error NotImplementedError
    end
  end
end
