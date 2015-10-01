describe ThemeJuice::Tasks::Stage do

  before do
    @env = ThemeJuice::Env
    expect_any_instance_of(@env).to receive(:stage)
      .at_least(:once).and_return "production"
    @config = ThemeJuice::Config
    expect_any_instance_of(@config).to receive(:config)
      .at_least(:once).and_return YAML.load %Q{
deployment:
  stages:
    production:
      server: 192.168.50.4
      path: /var/www/production
      user: deploy
      url: example.com
      uploads: app/uploads
      tmp: tmp
      shared:
        - .htaccess
        - .env
        - shared/dir/
      ignore:
        - robots.txt
      roles:
        - :web
        - :app
        - :db
}
  end

  before :each do
    @task = ThemeJuice::Tasks::Stage.new
  end

  describe "#execute" do

    it "should set stage server" do
      expect(@task).to receive(:server).with "192.168.50.4", { :user => "deploy",
        :roles => [:web, :app, :db] }

      capture(:stdout) { @task.execute }
    end

    it "should set stage options" do
      expect(@task).to receive(:set).with(:deploy_to, kind_of(Proc))
        .and_return "/var/www/production"
      expect(@task).to receive(:set).with(:stage_url, kind_of(Proc))
        .and_return "example.com"
      expect(@task).to receive(:set).with(:uploads_dir, kind_of(Proc))
        .and_return "app/uploads"
      expect(@task).to receive(:set).with(:shared_files, kind_of(Proc))
        .and_return [".htaccess", ".env"]
      expect(@task).to receive(:set).with(:shared_dirs, kind_of(Proc))
        .and_return ["shared/dir"]
      expect(@task).to receive(:set).with(:tmp_dir, kind_of(Proc))
        .and_return "tmp"
      expect(@task).to receive(:set).with(:stage, kind_of(Proc))
        .and_return :production
      expect(@task).to receive(:set).with(:rsync_ignore, kind_of(Proc))
        .and_return ["robots.txt"]

      capture(:stdout) { @task.execute }
    end
  end
end
