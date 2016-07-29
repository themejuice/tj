describe ThemeJuice::Commands::Create do

  # @TODO Double to override the initialization process. This way we
  #  can go ahead and test the class methods. In the future this
  #  should probably be decoupled.
  class CreateCommandDouble < ThemeJuice::Commands::Create
    def initialize
      @env     = ThemeJuice::Env
      @io      = ThemeJuice::IO
      @project = ThemeJuice::Project
      @config  = ThemeJuice::Config
    end
  end

  before do
    @create = ThemeJuice::Commands::Create
    @double = CreateCommandDouble.new
  end

  describe "#execute" do
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
        kind_of(Hash)).exactly(7).times.and_return "n",
          "db_host",
          "db_name",
          "db_user",
          "db_pass",
          "n",
          "n"

      expect(@create.new).to be
    end

    it "should raise error for project name containing special characters" do
      expect(stdout).to receive(:print).at_least(:once)

      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).and_return "./+=_)\\;;"

      expect { @double.send(:name) }.to raise_error SystemExit
    end

    it "should raise error for project name containing capital letters" do
      expect(stdout).to receive(:print).at_least(:once)

      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).and_return "Test-Project"

      expect { @double.send(:name) }.to raise_error SystemExit
    end

    it "should raise error for project name containing underscores" do
      expect(stdout).to receive(:print).at_least(:once)

      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).and_return "test_project"

      expect { @double.send(:name) }.to raise_error SystemExit
    end

    it "should raise error for an invalid project url TLD" do
      expect(stdout).to receive(:print).at_least(:once)

      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).and_return "project.invalid"

      expect { @double.send(:url) }.to raise_error SystemExit
    end

    it "should raise error for project url containing capital letters" do
      expect(stdout).to receive(:print).at_least(:once)

      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).and_return "Test-Project.dev"

      expect { @double.send(:url) }.to raise_error SystemExit
    end

    it "should raise error for project url containing underscores" do
      expect(stdout).to receive(:print).at_least(:once)

      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).and_return "test_project.dev"

      expect { @double.send(:url) }.to raise_error SystemExit
    end

    context "when given a location path containing a tilde" do

      it "should correctly expand the tilde path" do
        allow(stdout).to receive :print

        expect(thor_stdin).to receive(:readline).with(kind_of(String),
          kind_of(Hash)).and_return "~/tilde-project-path"

        expect(@double.send(:location)).to match "#{Dir.home}/tilde-project-path"
      end
    end

    context "when given a relative location path" do

      before do
        allow(Dir).to receive(:pwd).and_return "/some/absolute/path"
      end

      it "should append relative path to current directory" do
        allow(stdout).to receive :print

        expect(thor_stdin).to receive(:readline).with(kind_of(String),
          kind_of(Hash)).and_return "relative-project-path"

        expect(@double.send(:location)).to match "/some/absolute/path/relative-project-path"
      end
    end

    context "when given an absolute location path" do

      before do
        allow(Dir).to receive(:pwd).and_return "/some/absolute/path"
      end

      it "should not modify absolute path" do
        allow(stdout).to receive :print

        expect(thor_stdin).to receive(:readline).with(kind_of(String),
          kind_of(Hash)).and_return "/absolute-project-path"

        expect(@double.send(:location)).to match "/absolute-project-path"
      end
    end

    context "when given a dot for location path" do

      before do
        allow(Dir).to receive(:pwd).and_return "/the/current/directory"
      end

      it "should use the current directory" do
        allow(stdout).to receive :print

        expect(thor_stdin).to receive(:readline).with(kind_of(String),
          kind_of(Hash)).and_return "."

        expect(@double.send(:location)).to match "/the/current/directory"
      end
    end
  end
end
