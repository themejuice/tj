describe ThemeJuice::IO do

  before do
    @io = ThemeJuice::IO
  end

  describe ".say" do

    it "should output a message to $stdout" do
      output = capture(:stdout) { @io.say "According to my calculations..." }
      expect(output).to be_a String
    end

    it "should output plain message when Env.robot is true" do
      allow(ThemeJuice::Env).to receive(:robot).and_return true

      output = capture(:stdout) { @io.say "Some plain ol' boring message" }
      expect(output).to match "Some plain ol' boring message\n"
    end
  end

  describe ".prompt" do
    it "should prompt to $stdout and receive input from $stdin" do
      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).and_return "Augustine"
      expect(@io.ask("What is thy name?")).to eq "Augustine"
    end
  end

  describe ".agree?" do
    it "should prompt to $stdout and receive Y/n from $stdin" do
      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).and_return "Y"
      expect(@io.agree?("So, is that a yes?")).to eq true
    end
  end

  describe ".success" do
    it "should output a success message to $stdout" do
      output = capture(:stdout) { @io.success "Victory is ours!" }
      expect(output).to be_a String
    end
  end

  describe ".notice" do
    it "should output a notice to $stdout" do
      output = capture(:stdout) { @io.notice "Tonight, we dine in hell!" }
      expect(output).to be_a String
    end
  end

  describe ".error" do

    it "should output error message to $stdout" do
      expect(stdout).to receive(:print).with kind_of String
      expect { @io.error "Oh noes!" }.to raise_error SystemExit
    end

    it "should raise passed exception type when Env.trace is true" do
      allow(ThemeJuice::Env).to receive(:trace).and_return true

      expect(stdout).to receive(:print).with kind_of String
      expect { @io.error "Exception!", NotImplementedError }.to raise_error NotImplementedError
    end

    it "should raise SystemExit when Env.trace is false" do
      allow(ThemeJuice::Env).to receive(:trace).and_return false
      allow(stdout).to receive :print

      expect { @io.error "Oops!", NotImplementedError }.to raise_error SystemExit
      expect { @io.error "Exiting!" }.to raise_error SystemExit
    end
  end

  describe ".choose" do
    it "should allow using arrow keys to choose item in list" do
      expect(stdin).to receive(:noecho).with(no_args)
        .once.and_return "down",
          "down",
          "up",
          "down",
          "up",
          "down",
          "down",
          "return"

      capture(:stdout) do
        expect(@io.choose("list", :blue, ["one", "two", "three"])).to eq "three"
      end
    end
  end

  describe ".hello" do
    it "should output a hello message to $stdout" do
      output = capture(:stdout) { @io.hello }
      expect(output).to be_a String
    end
  end

  describe ".goodbye" do
    it "should output a goodbye message before exiting the program" do
      expect(stdout).to receive :print
      expect { @io.goodbye }.to raise_error SystemExit
    end
  end
end
