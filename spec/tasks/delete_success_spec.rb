describe ThemeJuice::Tasks::DeleteSuccess do

  before :each do
    @task = ThemeJuice::Tasks::DeleteSuccess.new
  end

  describe "#unexecute" do
    it "should output success to $stdout" do
      expect { @task.unexecute }.to output.to_stdout
    end
  end
end

