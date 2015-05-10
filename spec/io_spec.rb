require_relative "../lib/theme-juice"

describe ThemeJuice::IO do

  before do
    @io = ThemeJuice::IO
    ThemeJuice::Env.boring = true
  end

  describe "#speak" do
    it "should output to STDOUT" do
      expect($stdout).to receive(:print).with("Stuff n' thangs\n")
      @io.speak("Stuff n' thangs")
    end
  end

  describe "#prompt" do
    it "should output to STDOUT" do
      expect($stdout).to receive(:print).with("What shall thy name be?\n")
      @io.speak "What shall thy name be?"
    end
    it "should receive input from STDIN" do
      expect($stdin).to receive(:gets).with("Augustine")
      @io.speak "What shall thy name be?"
    end
  end
end
