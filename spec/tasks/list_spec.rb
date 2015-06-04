describe ThemeJuice::Tasks::List do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project
  end

  before :each do
    @task = ThemeJuice::Tasks::List.new
  end
  
  describe "#list" do
    
    it "should print all project names to $stdout" do
      expect { @task.list :projects }.to output.to_stdout
    end
    
    it "should raise error if prop does not exist" do
      expect { @task.list :urls }.to output.to_stdout
    end
    
    it "should raise error if prop does not exist" do
      expect(stdout).to receive :print
      expect { @task.list :prop }.to raise_error NotImplementedError
    end
  end

  describe "#projects" do
    it "should return an array of project names" do
      expect(@task.projects).to be_a Array
    end
  end

  describe "#urls" do
    it "should return an array of domain names" do
      expect(@task.urls).to be_a Array
    end
  end
end
