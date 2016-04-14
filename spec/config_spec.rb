describe ThemeJuice::Config do

  before :each do
    @env = ThemeJuice::Env
    @config = ThemeJuice::Config
  end

  describe ".config" do

    context "when config file does not exist" do

      before :each do
        expect_any_instance_of(@config).to receive(:config)
          .once.and_return nil
      end

      it "should not raise error" do
        expect { @config.config }.not_to raise_error
      end

      it "should not raise error if Env.trace is true" do
        allow(ThemeJuice::Env).to receive(:trace).and_return true
        expect { @config.config }.not_to raise_error
      end
    end

    describe ".command" do

      context "when receiving a command" do

        before :each do
          expect_any_instance_of(@config).to receive(:config)
            .once.and_return YAML.load %Q{
commands:
  install:
    - "%args%"
  watch: "%arguments%"
}
        end

        it "should not raise error if command exists in config" do
          allow(stdout).to receive :print
          expect { @config.command :install }.not_to raise_error
        end

        it "should raise error if command does not exist in config and Env.trace is true" do
          allow(ThemeJuice::Env).to receive(:trace).and_return true
          capture(:stdout) do
            expect { @config.command :invalid }.to raise_error NotImplementedError
          end
        end

        it "should output notice to $stdout if config is invalid" do
          capture(:stdout) do
            expect { @config.command :watch }.to output.to_stdout
          end
        end

        it "should not raise error if config is invalid" do
          capture(:stdout) do
            expect { @config.command :watch }.not_to raise_error
          end
        end
      end

      context "when receiving a command that exists in config" do

        before :each do
          expect_any_instance_of(@config).to receive(:config)
            .at_least(1).times.and_return YAML.load %Q{
commands:
  install:
    - "%args%"
  vendor:
    - "1:%arg1% 2:%arg2%"
    - "3:%arg3% 4:%arg4%"
  dist:
    - "1:%argument1% 2:%argument2% 3:%argument3% 4:%argument4%"
}
        end

        it "should map all args to single command" do
          allow(stdout).to receive :print
          expect { @config.command :install, ["1", "2", "3", "4"] }.to output(/1 2 3 4/).to_stdout
        end

        it "should reject all flags/switches inside given args" do
          allow(stdout).to receive :print
          expect { @config.command :install, ["a", "b", "-c", "--defg"] }.to_not output(/(-c|--defg)/).to_stdout
          expect { @config.command :install, ["a", "b", "-c", "--defg"] }.to output(/a b/).to_stdout
        end

        it "should map each arg to specific command" do
          allow(stdout).to receive :print
          expect { @config.command :dist, ["1", "2", "3", "4"] }.to output(/1:1 2:2 3:3 4:4/).to_stdout
        end

        it "should handle running multiple commands" do
          allow(stdout).to receive :print
          expect { @config.command :vendor, ["1", "2", "3", "4"] }.to output(/(1:1 2:2)(.*)?(3:3 4:4)/m).to_stdout
        end
      end

      context "when receiving a command with the Env.from_path flag" do

        before :each do
          allow(@env).to receive(:from_path).and_return "/some/path"
          allow(@env).to receive(:verbose).and_return true
          expect_any_instance_of(@config).to receive(:config)
            .once.and_return YAML.load %Q{
commands:
  install:
    - echo "test"
}
        end

        it "should execute the command from the given path" do
          allow(stdout).to receive :print
          expect { @config.command :install }.to output(/run  echo "test" from "\/some\/path"/).to_stdout
        end
      end

      context "when receiving a command without the Env.from_path flag" do

        before :each do
          allow(@env).to receive(:verbose).and_return true
          expect_any_instance_of(@config).to receive(:config)
            .once.and_return YAML.load %Q{
commands:
  install:
    - echo "test"
}
        end

        it "should execute the command from the current path" do
          allow(stdout).to receive :print
          expect { @config.command :install }.to output(/run  echo "test" from "\/"/).to_stdout
        end
      end

      context "when receiving a command with the Env.inside_vm flag" do

        before :each do
          allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
          allow(@env).to receive(:inside_vm).and_return true
          allow(@env).to receive(:verbose).and_return true
          allow(@env).to receive(:dryrun).and_return true
          expect_any_instance_of(@config).to receive(:config)
            .once.and_return YAML.load %Q{
commands:
  install:
    - echo "test"
}
        end

        it "should execute the command from inside the VM using cwd as project name" do
          allow(stdout).to receive :print
          expect { @config.command :install }.to output(
            /run  vagrant ssh -c 'cd \/srv\/www\/project && echo "test"' from "\/[^\/]+\/[^\/]+\/tj-vagrant-test"/
          ).to_stdout
        end
      end

      context "when receiving a command with the Env.inside_vm and Env.from_srv flag" do

        before :each do
          allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
          allow(@env).to receive(:from_srv).and_return "/some/path"
          allow(@env).to receive(:inside_vm).and_return true
          allow(@env).to receive(:verbose).and_return true
          allow(@env).to receive(:dryrun).and_return true
          expect_any_instance_of(@config).to receive(:config)
            .once.and_return YAML.load %Q{
commands:
  install:
    - echo "test"
}
        end

        it "should execute the command from the given path inside the VM" do
          allow(stdout).to receive :print
          expect { @config.command :install }.to output(
            /run  vagrant ssh -c 'cd \/some\/path && echo "test"' from "\/[^\/]+\/[^\/]+\/tj-vagrant-test"/
          ).to_stdout
        end
      end
    end

    describe ".deployment" do

      context "when deployment info exists in config" do

        before :each do
          expect_any_instance_of(@config).to receive(:config)
            .once.and_return YAML.load %Q{
deployment:
  application:
    name: test-app
  stages:
    staging:
      server: 192.168.1.1
      path: /abcdefg/hijklmnop/
}
        end

        it "should not raise error" do
          allow(stdout).to receive :print
          expect { @config.deployment }.not_to raise_error
        end

        it "should raise error if Env.trace is true" do
          allow(ThemeJuice::Env).to receive(:trace).and_return true
          allow(stdout).to receive :print
          expect { @config.deployment }.not_to raise_error
        end
      end

      context "when deployment info does not exist in config" do

        before :each do
          expect_any_instance_of(@config).to receive(:config)
            .once.and_return YAML.load %Q{
commands:
  install:
    - "%args%"
}
        end

        it "should exit when deployment info is missing" do
          allow(stdout).to receive :print
          expect { @config.deployment }.to raise_error SystemExit
        end

        it "should raise error for missing deployment info when Env.trace is true" do
          allow(ThemeJuice::Env).to receive(:trace).and_return true
          allow(stdout).to receive :print
          expect { @config.deployment }.to raise_error NotImplementedError
        end
      end
    end

    describe ".exist?" do

      context "when config exists" do

        before :each do
          expect_any_instance_of(@config).to receive(:config)
            .once.and_return YAML.load %Q{
commands:
  install:
    - "%args%"
  watch: "%arguments%"
}
        end

        it "should return true" do
          expect(@config.exist?).to be true
        end
      end

      context "when config does not exist" do
        it "should return false" do
          expect(@config.exist?).to be false
        end
      end
    end
  end
end
