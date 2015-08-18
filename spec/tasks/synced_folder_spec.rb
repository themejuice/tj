describe ThemeJuice::Tasks::SyncedFolder do

  before do
    @env     = ThemeJuice::Env
    @project = ThemeJuice::Project
    
    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@project).to receive(:name).and_return "synced-folder-test"
    allow(@project).to receive(:location).and_return Dir.pwd
    
    FileUtils.mkdir_p "#{@env.vm_path}"
    FileUtils.touch "#{@env.vm_path}/Customfile"
  end

  before :each do
    @task = ThemeJuice::Tasks::SyncedFolder.new
    @file = "#{@env.vm_path}/Customfile"
  end

  describe "#execute" do
    it "should append synced folder info to customfile" do
      output = capture(:stdout) { @task.execute }
      
      expect(File.binread(@file)).to match /config\.vm\.synced_folder/
      expect(File.binread(@file)).to match /#{@project.name}/
      expect(File.binread(@file)).to match /#{@project.location}/
    end
  end

  describe "#unexecute" do
    it "should gsub synced folder info from customfile" do
      output = capture(:stdout) { @task.unexecute }
      
      expect(File.binread(@file)).not_to match /config\.vm\.synced_folder/
      expect(File.binread(@file)).not_to match /#{@project.name}/
      expect(File.binread(@file)).not_to match /#{@project.location}/
      
      expect(output).to match /gsub/
    end
  end
end
