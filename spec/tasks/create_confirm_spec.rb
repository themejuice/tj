describe ThemeJuice::Tasks::CreateConfirm do

  before :each do
    @task = ThemeJuice::Tasks::CreateConfirm.new
  end

  describe "#execute" do

    it "should confirm project settings when 'Y' is passed" do
      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).once.and_return "Y"

      expect { @task.execute }.to output.to_stdout
    end

    it "should exit when 'n' is passed" do
      allow(stdout).to receive(:print)

      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).once.and_return "n"

      expect { @task.execute }.to raise_error SystemExit
    end
  end
end
