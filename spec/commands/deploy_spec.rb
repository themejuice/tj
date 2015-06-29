describe ThemeJuice::Commands::Deploy do

  before do
    @env = ThemeJuice::Env
    @deploy = ThemeJuice::Commands::Deploy
    @config = ThemeJuice::Config
    expect_any_instance_of(@config).to receive(:config)
      .at_least(:once).and_return YAML.load %Q{
deployment:
  stages:
    staging:
      server: 192.168.50.4
      path: /srv/www/tj-example
      user: vagrant
      url: example.dev
      uploads: app/uploads
      tmp: tmp
      shared:
        - .htaccess
        - .env
      roles:
        - :web
        - :app
        - :db
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

  describe "#execute" do

    it "should create a capistrano application instance" do
      capture(:stdout) { @deploy.new.staging }

      expect(@env.cap).to be_a Capistrano::Application
    end

    it "should set the Env.stage to passed deployment stage" do
      capture(:stdout) { @deploy.new.staging }

      expect(@env.stage).to eq :staging
      expect(@env.stage).to_not eq :production
      expect(@env.stage).to_not eq :development
    end

    it "should raise error if passed an invalid stage" do
      expect(stdout).to receive :print

      expect { @deploy.new.random }.to raise_error SystemExit
    end
  end
end
