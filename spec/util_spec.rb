describe ThemeJuice::Util do

  before do
    @env = ThemeJuice::Env
    
    allow(@env).to receive(:vm_path).and_return Dir.pwd
    allow(@env).to receive(:verbose).and_return false
    allow(@env).to receive(:dryrun).and_return true
  end

  before :each do
    @util = ThemeJuice::Util.new
  end

  describe "#run" do

    it "should yield when given a block" do
      expect(stdout).to receive(:print).once
      expect { |b| @util.run([], &b) }.to yield_control
    end

    it "should run a single command" do
      output = capture(:stdout) { @util.run "a command" }
      expect(output).to be_a String
    end

    it "should run multiple commands" do
      output = capture(:stdout) do
        @util.run [] do |cmds|
          cmds << "1"
          cmds << "2"
        end
      end

      expect(output).to be_a String
      expect(output).to match /&&/
    end
  end

  describe "#run_inside_vm" do

    it "should run a single command inside the vm" do
      output = capture(:stdout) { @util.run_inside_vm "a command" }

      expect(output).to be_a String
      expect(output).to match /vagrant ssh/
    end

    it "should run multiple commands inside the vm" do
      output = capture(:stdout) do
        @util.run_inside_vm [] do |cmds|
          cmds << "1"
          cmds << "2"
        end
      end

      expect(output).to be_a String
      expect(output).to match /&&/
      expect(output).to match /vagrant ssh/
    end
  end
end
