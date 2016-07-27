describe ThemeJuice::Tasks::WPCLI do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:vm_ip).and_return "192.168.13.37"
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

    context "when Project.no_wp is false" do

      before do
        allow(@project).to receive(:no_wp).and_return false
      end

      it "should create wp-cli local file" do
        output = capture(:stdout) { @task.execute }

        expect(File.binread(@file)).to match /@development/
        expect(File.binread(@file)).to match /\/srv\/www\/wp-cli-test\//
        expect(File.binread(@file)).to match /192\.168\.13\.37/

        expect(output).to match /create/
      end
    end

    context "when Project.no_wp_cli is false" do

      before do
        allow(@project).to receive(:no_wp_cli).and_return false
      end

      it "should create wp-cli local file" do
        output = capture(:stdout) { @task.execute }

        expect(File.binread(@file)).to match /@development/
        expect(File.binread(@file)).to match /\/srv\/www\/wp-cli-test\//
        expect(File.binread(@file)).to match /192\.168\.13\.37/

        expect(output).to match /create/
      end
    end

    context "when Project.no_wp is true" do

      before do
        allow(@project).to receive(:no_wp).and_return true
      end

      it "should not create wp-cli local file" do
        output = capture(:stdout) { @task.execute }

        expect(File.exist?(@file)).to be false
      end
    end

    context "when Project.no_wp_cli is true" do

      before do
        allow(@project).to receive(:no_wp_cli).and_return true
      end

      it "should not create wp-cli local file" do
        output = capture(:stdout) { @task.execute }

        expect(File.exist?(@file)).to be false
      end
    end
  end

  describe "#unexecute" do
    it "should remove wp-cli local file" do
      output = capture(:stdout) do
        @task.execute
        @task.unexecute
      end

      expect(File.exist?(@file)).to be false

      expect(output).to match /remove/
    end
  end
end
