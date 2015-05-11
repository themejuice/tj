describe ThemeJuice::Commands::Create do

  before do
    @create = ThemeJuice::Commands::Create
  end

  describe "#new" do
    it "should successfully go through create steps" do
      expect(stdout).to receive(:print).at_least(10).times

      # First couple of prompts
      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).exactly(3).times.and_return "project",
          "#{Dir.pwd}",
          "project.dev"

      # Select menu
      expect(stdin).to receive(:noecho).with(no_args)
        .once.and_return "down",
          "down",
          "return"

      # Rest of the prompts
      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).exactly(6).times.and_return "n",
          "db_host",
          "db_name",
          "db_user",
          "db_pass",
          "n"

      expect(@create.new).to be
    end

    it "should raise error for invalid project name" do
      expect(stdout).to receive(:print).at_least(:once)

      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).once.and_return "./+=_)\\;;"

      expect { @create.new }.to raise_error SystemExit
    end

    it "should raise error for invalid project url" do
      expect(stdout).to receive(:print).at_least(:once)

      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).exactly(3).and_return "project",
          "#{Dir.pwd}",
          "project.invalid"

      expect { @create.new }.to raise_error SystemExit
    end
  end
end
