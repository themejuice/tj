describe ThemeJuice::Tasks::VMCustomfile do

  before do
    @env = ThemeJuice::Env

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    
    FileUtils.mkdir_p "#{@env.vm_path}"
  end

  before :each do
    @task = ThemeJuice::Tasks::VMCustomfile.new
    @file = "#{@env.vm_path}/Customfile"
  end

  describe "#execute" do
    it "should create the customfile" do
      output = capture(:stdout) { @task.execute }
      
      expect(File.exist?(@file)).to be true
      
      expect(output).to match /create/
    end
  end

  describe "#unexecute" do
    it "should remove the customfile" do
      output = capture(:stdout) do
        @task.execute
        @task.unexecute
      end
      
      expect(File.exist?(@file)).to be false
      
      expect(output).to match /remove/
    end
  end
end
