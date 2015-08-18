describe ThemeJuice::Tasks::VMRestart do

  before do
    @env     = ThemeJuice::Env
    @project = ThemeJuice::Project
    
    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@env).to receive(:dryrun).and_return true
    allow(@project).to receive(:vm_restart).and_return false
  end

  before :each do
    @task = ThemeJuice::Tasks::VMRestart.new
  end

  describe "#execute" do
    it "should restart vagrant" do
      output = capture(:stdout) { @task.execute }
      
      expect(output).to match /vagrant reload/
    end
  end
  
  describe "#unexecute" do
    
    context "when Project.vm_restart is set to true" do
      
      before do
        allow(@project).to receive(:vm_restart).and_return true
      end
      
      it "should restart vagrant" do
        output = capture(:stdout) { @task.unexecute }
        
        expect(output).to match /vagrant reload/
      end
    end
    
    context "when Project.vm_restart is set to false" do
      it "should not restart vagrant" do
        output = capture(:stdout) { @task.unexecute }
        
        expect(output).to_not match /vagrant reload/
      end
    end
  end
end
