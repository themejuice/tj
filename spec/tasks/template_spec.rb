describe ThemeJuice::Tasks::Template do

  before do
    @env     = ThemeJuice::Env
    @project = ThemeJuice::Project
    @config  = ThemeJuice::Config

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@env).to receive(:dryrun).and_return true
    allow(@project).to receive(:name).and_return "synced-folder-test"
    allow(@project).to receive(:location).and_return Dir.pwd
    allow(@project).to receive(:template).and_return "git@github.com:some/unknown/repo.git"
    expect_any_instance_of(@config).to receive(:config)
      .at_least(:once).and_return YAML.load %Q{
commands:
  install:
    - "Installing template..."
    - "Done!"
}

    FileUtils.mkdir_p "#{@env.vm_path}"
  end

  before :each do
    @task = ThemeJuice::Tasks::Template.new
  end

  describe "#execute" do

    it "should clone template repository into project location" do
      output = capture(:stdout) { @task.execute }

      expect(output).to match /git clone/
      expect(output).to match /#{@project.template}/
    end

    it "should run template installation from config file" do
      output = capture(:stdout) { @task.execute }

      expect(output).to match /Installing template\.\.\./
      expect(output).to match /Done\!/
    end
  end
end
