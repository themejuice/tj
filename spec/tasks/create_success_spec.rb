describe ThemeJuice::Tasks::CreateSuccess do

  before :each do
    @task = ThemeJuice::Tasks::CreateSuccess.new
  end

  describe "#execute" do

    it "should output success to $stdout when 'Y' is passed" do
      # expect_any_instance_of(ThemeJuice::Tasks::VMProvision)
      #   .to receive(:execute).once

      # expect(thor_stdin).to receive(:readline).with(kind_of(String),
      #   kind_of(Hash)).once.and_return "Y"

      expect { @task.execute }.to output.to_stdout
    end

    it "should output to $stdout and skip when 'n' is passed" do
      # expect(thor_stdin).to receive(:readline).with(kind_of(String),
      #   kind_of(Hash)).once.and_return "n"

      expect { @task.execute }.to output.to_stdout
    end
  end
end
