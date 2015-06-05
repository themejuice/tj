describe ThemeJuice::Tasks::Repo do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project
    
    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@env).to receive(:dryrun).and_return true
    allow(@project).to receive(:location).and_return "#{@env.vm_path}"
    allow(@project).to receive(:repository).and_return "https://github.com/some/unknown/repo.git"
    
    FileUtils.mkdir_p "#{@env.vm_path}/.git"
  end

  before :each do
    @task = ThemeJuice::Tasks::Repo.new
  end
  
  describe "#execute" do
    it "should init new and remove existing repository when user passes 'Y'" do
      allow(stdout).to receive :print
      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).at_least(:once).and_return "Y"
          
      expect { @task.execute }.to output(/git init/).to_stdout
      expect { @task.execute }.to output(/git remote add origin #{@project.repository}/).to_stdout
      expect { @task.execute }.to_not output(/remote origin already exists/).to_stdout
    end
    
    it "should exit when the user passes 'n' to removal prompt" do
      allow(stdout).to receive :print
      expect(thor_stdin).to receive(:readline).with(kind_of(String),
        kind_of(Hash)).at_least(:once).and_return "n"
          
      expect { @task.execute }.to raise_error SystemExit
    end
  end
end
