describe ThemeJuice::Util do

  before do
    @env = ThemeJuice::Env

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@env).to receive(:quiet).and_return false
    allow(@env).to receive(:dryrun).and_return true
  end

  before :each do
    @util = ThemeJuice::Util.new
  end

  describe "#run" do

    it "should yield when given a block" do
      expect(stdout).to receive :print
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

    context "when Env.quiet is true" do

      before :each do
        allow(@env).to receive(:verbose).and_return false
        allow(@env).to receive(:quiet).and_return true
      end

      it "should not output to $stdout with single command" do
        config = {
          :verbose => @env.verbose,
          :capture => @env.quiet
        }

        expect { @util.run "echo 'a command'", config }.to_not output.to_stdout
      end

      it "should not output to $stdout with multiple commands" do
        config = {
          :verbose => @env.verbose,
          :capture => @env.quiet
        }

        expect do
          @util.run [], config do |cmds|
            cmds << "echo 'a command'"
            cmds << "echo 'another command'"
          end
        end.to_not output.to_stdout
      end
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

    context "when Env.quiet is true" do

      before :each do
        allow(@env).to receive(:verbose).and_return false
        allow(@env).to receive(:quiet).and_return true
      end

      it "should not output to $stdout with single command" do
        config = {
          :verbose => @env.verbose,
          :capture => @env.quiet
        }

        expect { @util.run_inside_vm "echo 'a command'", config }.to_not output.to_stdout
      end

      it "should not output to $stdout with multiple commands" do
        config = {
          :verbose => @env.verbose,
          :capture => @env.quiet
        }

        expect do
          @util.run_inside_vm [], config do |cmds|
            cmds << "echo 'a command'"
            cmds << "echo 'another command'"
          end
        end.to_not output.to_stdout
      end
    end
  end
end
