describe ThemeJuice::IO do

  before do
    @io = ThemeJuice::IO
  end

  describe "#speak" do
    it "should output to $stdout" do
      output = capture(:stdout) { @io.speak "According to my calculations..." }
      expect(output).to be_a String
    end
  end

  describe "#prompt" do
    it "should output to $stdout and receive input from $stdin" do
      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).and_return("Augustine")
      expect(@io.prompt("What is thy name?")).to eq "Augustine"
    end
  end

  describe "#agree?" do
    it "should prompt to $stdout and receive input from $stdin" do
      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).and_return("Y")
      expect(@io.agree?("So, is that a yes?")).to eq true
    end
  end

  describe "#success" do
    it "should output to $stdout" do
      output = capture(:stdout) { @io.success "Victory is ours!" }
      expect(output).to be_a String
    end
  end

  describe "#notice" do
    it "should output to $stdout" do
      output = capture(:stdout) { @io.notice "Tonight, we dine in hell!" }
      expect(output).to be_a String
    end
  end

  describe "#error" do
    it "should output to $stdout" do
      expect(stdout).to receive(:print).with kind_of String
      expect { @io.error "Oh noes!" }.to raise_error SystemExit
    end
  end

  describe "#choose" do
    it "should output to $stdout and take input from $stdin" do
      expect(stdin).to receive(:noecho).with(no_args)
        .once.and_return "down",
          "down",
          "down",
          "return"

      capture(:stdout) do
        expect(@io.choose("list", :blue, ["one", "two", "three"])).to eq "three"
      end
    end
  end
end
