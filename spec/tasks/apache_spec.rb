describe ThemeJuice::Tasks::Apache do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant")
    allow(@env).to receive(:verbose).and_return true
    allow(@project).to receive(:name).and_return "test_apache"
    allow(@project).to receive(:url).and_return "test.dev"
    allow(@project).to receive(:vm_srv).and_return "/srv/www/apache-test/"
    
    FakeFS::FileSystem.clone "#{@env.vm_path}/config/apache-config/sites/#{@project.name}.conf"
  end

  before :each do
    @task = ThemeJuice::Tasks::Apache.new
    @file = "#{@env.vm_path}/config/apache-config/sites/#{@project.name}.conf"
  end

  describe "#execute" do
    
    it "should create apache conf file with project info" do
      output = capture(:stdout) { @task.execute }
      
      expect(File.binread(@file)).to match /\/srv\/www\/apache-test\//
      expect(File.binread(@file)).to match /test.dev/
      
      expect(output).to match /create/
    end
  end

  describe "#unexecute" do
    it "should remove apache conf file" do
      output = capture(:stdout) do
        @task.execute
        @task.unexecute
      end
      
      expect(File.exist?(@file)).to be false
      
      expect(output).to match /remove/
    end
  end
end
