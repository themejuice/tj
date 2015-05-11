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
      expect(stdin).to receive(:readline).with(kind_of(String),
        {}).and_return("Augustine")
      expect(@io.prompt("What is thy name?")).to eq "Augustine"
    end
  end

  describe "#agree?" do
    it "should prompt to $stdout and receive input from $stdin" do
      expect(stdin).to receive(:readline).with(kind_of(String),
        :add_to_history => false).and_return("Y")
      expect(@io.agree?("Are you sure?")).to eq true
    end
  end

  describe "#success" do
    it "should output to $stdout" do
      output = capture(:stdout) { @io.success "Success" }
      expect(output).to be_a String
    end
  end

  describe "#notice" do
    it "should output to $stdout" do
      output = capture(:stdout) { @io.notice "Notice" }
      expect(output).to be_a String
    end
  end

  describe "#error" do
    it "should output to $stdout" do
      expect(stdout).to receive(:print).with kind_of String
      expect { @io.error "Error" }.to raise_error SystemExit
    end
  end
end
