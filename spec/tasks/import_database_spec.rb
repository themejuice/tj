describe ThemeJuice::Tasks::ImportDatabase do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project
    
    allow(@env).to receive(:vm_path).and_return Dir.pwd
    allow(@env).to receive(:verbose).and_return true
    allow(@env).to receive(:dryrun).and_return true
    allow(@project).to receive(:vm_srv).and_return Dir.pwd
    allow(@project).to receive(:db_import).and_return "test.sql"
  end

  before :each do
    @task = ThemeJuice::Tasks::ImportDatabase.new
  end
  
  describe "#execute" do
    it "should run database import commands inside vm" do
      output = capture(:stdout) { @task.execute }
      
      expect(output).to be_a String
      expect(output).to match /&&/
      expect(output).to match /vagrant ssh/
    end
  end
end
