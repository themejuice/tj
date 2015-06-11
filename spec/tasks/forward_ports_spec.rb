describe ThemeJuice::Tasks::ForwardPorts do

  before do
    @env = ThemeJuice::Env

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant-test")
    allow(@env).to receive(:verbose).and_return true

    FileUtils.mkdir_p "#{@env.vm_path}"
    FileUtils.touch "#{@env.vm_path}/Customfile"
  end

  before :each do
    @task = ThemeJuice::Tasks::ForwardPorts.new
    @file = "#{@env.vm_path}/Customfile"
  end

  describe "#execute" do

    it "should append port forwarding info to customfile" do
      output = capture(:stdout) { @task.execute }

      expect(File.binread(@file)).to match /config\.vm\.network "forwarded_port", guest: 80,  host: 8080/
      expect(File.binread(@file)).to match /config\.vm\.network "forwarded_port", guest: 443, host: 8443/

      expect(output).to match /append/
    end

    context "when using an osx machine" do
      it "should append host port forwarding triggers to customfile" do
        expect(OS).to receive(:osx?).and_return true

        output = capture(:stdout) { @task.execute }

        expect(File.binread(@file)).to match /rdr pass inet proto tcp from any to any port 80 -> 127\.0\.0\.1 port 8080/
        expect(File.binread(@file)).to match /rdr pass inet proto tcp from any to any port 443 -> 127\.0\.0\.1 port 8443/

        expect(output).to match /append/
      end
    end

    context "when not using an osx machine" do
      it "should not append host port forwarding triggers to customfile" do
        expect(OS).to receive(:osx?).and_return false

        output = capture(:stdout) { @task.execute }

        expect(File.binread(@file)).to_not match /rdr pass inet proto tcp from any to any port 80 -> 127\.0\.0\.1 port 8080/
        expect(File.binread(@file)).to_not match /rdr pass inet proto tcp from any to any port 443 -> 127\.0\.0\.1 port 8443/
      end
    end
  end

  describe "#unexecute" do
    it "should gsub port forwarding info from customfile" do
      output = capture(:stdout) { @task.unexecute }

      expect(File.binread(@file)).not_to match /config\.vm\.network "forwarded_port", guest: 80,  host: 8080/
      expect(File.binread(@file)).not_to match /config\.vm\.network "forwarded_port", guest: 443, host: 8443/

      expect(output).to match /gsub/
    end
  end
end
