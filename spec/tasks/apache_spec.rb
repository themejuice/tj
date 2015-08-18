describe ThemeJuice::Tasks::Apache do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@project).to receive(:name).and_return "apache-test"
    allow(@project).to receive(:url).and_return "apache-test.dev"
    allow(@project).to receive(:xip_url).and_return "apache-test"
    allow(@project).to receive(:vm_srv).and_return "/srv/www/apache-test/"

    FileUtils.mkdir_p "#{@env.vm_path}/config/apache-config/sites"
  end

  before :each do
    @task = ThemeJuice::Tasks::Apache.new
    @file = "#{@env.vm_path}/config/apache-config/sites/#{@project.name}.conf"
  end

  describe "#execute" do
    it "should create apache conf file with project info" do
      output = capture(:stdout) { @task.execute }

      expect(File.binread(@file)).to include '/srv/www/apache-test/'
      expect(File.binread(@file)).to include 'apache-test.dev'
      expect(File.binread(@file)).to include '*.apache-test.*.xip.io'

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
