describe ThemeJuice::Tasks::VMPlugins do

  before do
    @env     = ThemeJuice::Env
    @project = ThemeJuice::Project
    
    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@env).to receive(:dryrun).and_return true
    allow_any_instance_of(Kernel).to receive(:`).with(/vagrant/).and_return ""
  end

  before :each do
    @task = ThemeJuice::Tasks::VMPlugins.new
  end

  describe "#execute" do
    
    it "should install all specified vagrant plugins" do
      output = capture(:stdout) { @task.execute }
      
      expect(output).to match /vagrant-triggers/
      expect(output).to match /vagrant-hostsupdater/
      expect(output).to match /landrush/
    end
    
    context "when Env#no_landrush is set to true" do
      
      before do
        allow(@env).to receive(:no_landrush).and_return true
      end
      
      it "should not install the landrush vagrant plugin" do
        output = capture(:stdout) { @task.execute }
        
        expect(output).to match /vagrant-triggers/
        expect(output).to match /vagrant-hostsupdater/
        expect(output).not_to match /landrush/
      end
    end
  end
end
