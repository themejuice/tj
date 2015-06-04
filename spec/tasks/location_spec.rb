describe ThemeJuice::Tasks::Location do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project
    
    allow(@project).to receive(:location).and_return "#{Dir.pwd}/some/location"
    
    FakeFS::FileSystem.clone "#{Dir.pwd}/some/location"
  end

  before :each do
    @task = ThemeJuice::Tasks::Location.new
  end
  
  describe "#execute" do
    it "should create project directory path" do
      expect(File.exist?(@project.location)).to be false
      
      expect { @task.execute }.to output.to_stdout
      
      expect(File.exist?(@project.location)).to be true
    end
  end
end
