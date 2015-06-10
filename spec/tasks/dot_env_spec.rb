describe ThemeJuice::Tasks::DotEnv do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant-test")
    allow(@env).to receive(:vm_ip).and_return "1.1.1.1"
    allow(@env).to receive(:no_landrush).and_return false
    allow(@env).to receive(:verbose).and_return true

    allow(@project).to receive(:name).and_return "test"
    allow(@project).to receive(:location).and_return "#{@env.vm_path}/www/test"
    allow(@project).to receive(:url).and_return "test.dev"
    allow(@project).to receive(:db_host).and_return "test_db_host"
    allow(@project).to receive(:db_name).and_return "test_db_name"
    allow(@project).to receive(:db_user).and_return "test_db_user"
    allow(@project).to receive(:db_pass).and_return "test_db_pass"
    allow(@project).to receive(:no_wp).and_return false

    FileUtils.mkdir_p "#{@env.vm_path}/www/test"
  end

  before :each do
    @task = ThemeJuice::Tasks::DotEnv.new
    @file = "#{@env.vm_path}/www/test/.env"
  end

  describe "#execute" do
    it "should create .env file and append project info" do
      output = capture(:stdout) { @task.execute }

      expect(File.binread(@file)).to match /test\.dev/
      expect(File.binread(@file)).to match /test_db_host/
      expect(File.binread(@file)).to match /test_db_name/
      expect(File.binread(@file)).to match /test_db_user/
      expect(File.binread(@file)).to match /test_db_pass/

      expect(output).to match /create/
    end
  end

  describe "#unexecute" do
    it "should remove a created .env file" do
      output = capture(:stdout) do
        @task.execute
        @task.unexecute
      end

      expect(File.exist?(@file)).to be false

      expect(output).to match /remove/
    end
  end
end
