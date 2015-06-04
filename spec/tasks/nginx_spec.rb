describe ThemeJuice::Tasks::Nginx do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant")
    allow(@env).to receive(:verbose).and_return true
    allow(@project).to receive(:name).and_return "test_nginx"
    allow(@project).to receive(:url).and_return "test.dev"
    allow(@project).to receive(:vm_srv).and_return "/srv/www/nginx-test/"
    
    FakeFS::FileSystem.clone "#{@env.vm_path}/config/nginx-config/sites/#{@project.name}.conf"
  end

  before :each do
    @task = ThemeJuice::Tasks::Nginx.new
    @file = "#{@env.vm_path}/config/nginx-config/sites/#{@project.name}.conf"
  end

  describe "#execute" do
    
    it "should create nginx conf file with project info" do
      output = capture(:stdout) { @task.execute }
      
      expect(File.binread(@file)).to match /\/srv\/www\/nginx-test\//
      expect(File.binread(@file)).to match /test.dev/
      
      expect(output).to match /create/
    end
  end

  describe "#unexecute" do
    it "should remove nginx conf file" do
      output = capture(:stdout) do
        @task.execute
        @task.unexecute
      end
      
      expect(File.exist?(@file)).to be false
      
      expect(output).to match /remove/
    end
  end
end
