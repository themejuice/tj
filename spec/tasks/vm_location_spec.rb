describe ThemeJuice::Tasks::VMLocation do

  before do
    @env     = ThemeJuice::Env
    @project = ThemeJuice::Project
    
    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@project).to receive(:vm_location).and_return "#{@env.vm_path}/vm-location-test"
    
    FileUtils.mkdir_p "#{@env.vm_path}"
  end

  before :each do
    @task = ThemeJuice::Tasks::VMLocation.new
  end

  describe "#execute" do
    it "should create the project location in vm" do
      output = capture(:stdout) { @task.execute }

      expect(Dir.exist?(@project.vm_location)).to be true
      
      expect(output).to match /create/
    end
  end

  describe "#unexecute" do
    it "should remove the project location in vm" do
      output = capture(:stdout) do
        @task.execute
        @task.unexecute
      end
      
      expect(Dir.exist?(@project.vm_location)).to be false
      
      expect(output).to match /remove/
    end
  end
end
