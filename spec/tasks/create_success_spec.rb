describe ThemeJuice::Tasks::CreateSuccess do

  before :each do
    @task = ThemeJuice::Tasks::CreateSuccess.new
  end

  describe "#execute" do
    it "should output success to $stdout" do
      expect { @task.execute }.to output.to_stdout
    end
  end
end
