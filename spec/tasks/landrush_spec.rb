describe ThemeJuice::Tasks::Landrush do

  before do
    @env = ThemeJuice::Env
    
    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@env).to receive(:no_landrush).and_return false
    
    FileUtils.mkdir_p "#{@env.vm_path}"
    FileUtils.touch "#{@env.vm_path}/Customfile"
  end

  before :each do
    @task = ThemeJuice::Tasks::Landrush.new
    @file = "#{@env.vm_path}/Customfile"
  end

  describe "#execute" do
    
    it "should append dns info to customfile" do
      output = capture(:stdout) { @task.execute }
      
      expect(File.binread(@file)).to match /config.landrush.enabled = true/
      expect(File.binread(@file)).to match /config.landrush.tld = 'dev'/
    end
  end

  describe "#unexecute" do
    it "should gsub dns info from customfile" do
      output = capture(:stdout) { @task.unexecute }
      
      expect(File.binread(@file)).not_to match /config.landrush.enabled = true/
      expect(File.binread(@file)).not_to match /config.landrush.tld = 'dev'/
      
      expect(output).to match /gsub/
    end
  end
end
