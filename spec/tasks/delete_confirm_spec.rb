describe ThemeJuice::Tasks::DeleteConfirm do

  before :each do
    @task = ThemeJuice::Tasks::DeleteConfirm.new
  end

  describe "#unexecute" do

    it "should confirm project removal when 'Y' is passed and not exit" do
      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).once.and_return "Y"

      expect { @task.unexecute }.to_not raise_error
    end

    it "should exit when 'n' is passed" do
      allow(stdout).to receive(:print)

      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).once.and_return "n"

      expect { @task.unexecute }.to raise_error SystemExit
    end
  end
end
