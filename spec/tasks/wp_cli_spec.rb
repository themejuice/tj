describe ThemeJuice::Tasks::WPCLI do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@project).to receive(:name).and_return "wp-cli-test"
    allow(@project).to receive(:url).and_return "wp-cli-test.dev"
    allow(@project).to receive(:location).and_return "#{@env.vm_path}/www/wp-cli-test"
    allow(@project).to receive(:vm_srv).and_return "/srv/www/wp-cli-test/"

    FileUtils.mkdir_p "#{@env.vm_path}/www/wp-cli-test"
  end

  before :each do
    @task = ThemeJuice::Tasks::WPCLI.new
    @file = "#{@project.location}/wp-cli.local.yml"
  end

  describe "#execute" do
    it "should create nginx conf file with project info" do
      output = capture(:stdout) { @task.execute }

      expect(File.binread(@file)).to match /wp-cli-test\.dev/
      expect(File.binread(@file)).to match /\/srv\/www\/wp-cli-test\//
      expect(File.binread(@file)).to match /\/tj-vagrant-test/

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
