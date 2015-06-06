describe ThemeJuice::Tasks::VMBox do

  before do
    @env = ThemeJuice::Env
    
    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant-test")
    allow(@env).to receive(:vm_box).and_return "git@github.com:some/vagrant/box.git"
    allow(@env).to receive(:verbose).and_return true
  end

  before :each do
    @task = ThemeJuice::Tasks::VMBox.new
  end

  describe "#execute" do
    it "should clone vagrant box to vm path" do
      output = capture(:stdout) { @task.execute }
      
      expect(output).to match /git clone/
      expect(output).to match /#{@env.vm_box}/
      expect(output).to match /#{@env.vm_path}/
    end
  end
end
