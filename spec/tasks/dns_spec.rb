describe ThemeJuice::Tasks::DNS do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:vm_ip).and_return "1.1.1.1"
    allow(@env).to receive(:no_landrush).and_return false
    allow(@env).to receive(:verbose).and_return true
    allow(@project).to receive(:name).and_return "dns-test"
    allow(@project).to receive(:url).and_return "dns-test.dev"
    
    FileUtils.mkdir_p "#{@env.vm_path}"
    FileUtils.touch "#{@env.vm_path}/Customfile"
  end

  before :each do
    @task = ThemeJuice::Tasks::DNS.new
    @file = "#{@env.vm_path}/Customfile"
  end

  describe "#execute" do
    it "should append dns info to customfile" do
      output = capture(:stdout) { @task.execute }
      
      expect(File.binread(@file)).to match /# Begin 'dns-test'/
      expect(File.binread(@file)).to match /dns-test\.dev/
      expect(File.binread(@file)).to match /1\.1\.1\.1/
      
      expect(output).to match /append/
    end
  end

  describe "#unexecute" do
    it "should gsub dns info from customfile" do
      output = capture(:stdout) { @task.unexecute }
      
      expect(File.binread(@file)).not_to match /# Begin 'dns-test'/
      expect(File.binread(@file)).not_to match /dns-test\.dev/
      expect(File.binread(@file)).not_to match /1\.1\.1\.1/
      
      expect(output).to match /gsub/
    end
  end
end
