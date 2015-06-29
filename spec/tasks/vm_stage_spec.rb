describe ThemeJuice::Tasks::VMStage do

  before do
    @env = ThemeJuice::Env
    @config = ThemeJuice::Config
    expect_any_instance_of(@config).to receive(:config)
      .at_least(:once).and_return YAML.load %Q{
deployment:
  stages:
    vagrant:
      server: example.dev
      path: /srv/www/tj-example
      user: vagrant
      pass: vagrant
      url: example.dev
      uploads: app/uploads
      backup: backup
      tmp: tmp
      roles:
        - :dev
}
  end

  before :each do
    @task = ThemeJuice::Tasks::VMStage.new
  end

  describe "#execute" do

    it "should set VM stage server" do
      expect(@task).to receive(:server).with "example.dev", { :user => "vagrant",
        :password => "vagrant", :roles => [:dev], :no_release => true }

      capture(:stdout) { @task.execute }
    end

    it "should set VM stage options" do
      expect(@task).to receive(:set).with(:dev_path, kind_of(Proc))
        .and_return "/srv/www/tj-example"
      expect(@task).to receive(:set).with(:vm_url, kind_of(Proc))
        .and_return "example.dev"
      expect(@task).to receive(:set).with(:vm_uploads_dir, kind_of(Proc))
        .and_return "app/uploads"
      expect(@task).to receive(:set).with(:vm_backup_dir, kind_of(Proc))
        .and_return "backup"
      expect(@task).to receive(:set).with(:vm_tmp_dir, kind_of(Proc))
        .and_return "tmp"

      capture(:stdout) { @task.execute }
    end
  end
end
