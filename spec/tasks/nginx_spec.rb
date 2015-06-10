describe ThemeJuice::Tasks::Nginx do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@project).to receive(:name).and_return "nginx-test"
    allow(@project).to receive(:url).and_return "nginx-test.dev"
    allow(@project).to receive(:vm_srv).and_return "/srv/www/nginx-test/"

    FileUtils.mkdir_p "#{@env.vm_path}/config/nginx-config/sites"
  end

  before :each do
    @task = ThemeJuice::Tasks::Nginx.new
    @file = "#{@env.vm_path}/config/nginx-config/sites/#{@project.name}.conf"
  end

  describe "#execute" do
    it "should create nginx conf file with project info" do
      output = capture(:stdout) { @task.execute }

      expect(File.binread(@file)).to include '/srv/www/nginx-test/'
      expect(File.binread(@file)).to include 'nginx-test.dev'
      expect(File.binread(@file)).to include '~^nginx-test\.\d+\.\d+\.\d+\.\d+\.xip\.io$'

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
