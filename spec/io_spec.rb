require_relative "helpers/spec_helper"
require_relative "../lib/theme-juice"

describe ThemeJuice::IO do

  def io
    ThemeJuice::IO
  end

  describe "#speak" do
    it "should output to $stdout" do
      output = capture(:stdout) { io.speak "According to my calculations..." }
      expect(output).to match(/According to my calculations.../)
    end
  end

  describe "#prompt" do
    it "should output to $stdout and receive input from $stdin" do
      expect(stdout).to receive(:print).with("What shal thy name be?\n")
      expect(stdin).to receive(:readline).with(" : ", {}).and_return("Augustine")
      expect(io.prompt("What is thy name?")).to eq("Augustine")
    end
  end

  describe "#agree?" do
    it "should prompt to $stdout and receive input from $stdin" do
      
    end
  end
end
