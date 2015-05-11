describe ThemeJuice::Commands::Delete do

  before do
    @delete = ThemeJuice::Commands::Delete
  end

  describe "#new" do
    it "should successfully go through delete steps" do
      expect_any_instance_of(ThemeJuice::Tasks::List)
        .to receive(:projects).once.and_return ["project"]
      expect_any_instance_of(ThemeJuice::Tasks::List)
        .to receive(:urls).once.and_return ["project.dev"]

      expect(thor_stdin).to receive(:readline).with(any_args)
        .exactly(2).times.and_return "project",
          "project.dev"

      expect(@delete.new).to be
    end

    it "should raise error for invalid project name" do
      expect_any_instance_of(ThemeJuice::Tasks::List)
        .to receive(:projects).once.and_return ["project"]

      expect(thor_stdin).to receive(:readline).with(any_args)
        .once.and_return "invalid-project"

      expect { capture(:stdout) { @delete.new } }.to raise_error SystemExit
    end

    it "should not raise error for invalid project url" do
      expect_any_instance_of(ThemeJuice::Tasks::List)
        .to receive(:projects).once.and_return ["project"]
      expect_any_instance_of(ThemeJuice::Tasks::List)
        .to receive(:urls).once.and_return ["project.dev"]

      expect(thor_stdin).to receive(:readline).with(any_args)
        .twice.and_return "project",
          "project.invalid"

      expect { @delete.new }.to output.to_stdout
    end
  end
end
