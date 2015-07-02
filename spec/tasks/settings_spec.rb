describe ThemeJuice::Tasks::Settings do

  before do
    @env = ThemeJuice::Env
    @config = ThemeJuice::Config
  end

  before :each do
    @task = ThemeJuice::Tasks::Settings.new
  end

  describe "#execute" do

    context "when given a valid config" do

      before do
        expect_any_instance_of(@config).to receive(:config)
          .at_least(:once).and_return YAML.load %Q{
deployment:
  application:
    name: example-app
  repository:
    repo_url: git@github.com:example/repo.git
    branch: :master
    scm: :rsync
  settings:
    keep_releases: 5
    use_sudo: false
  rsync:
    scm: :git
    options:
      - --recursive
      - --delete
      - --delete-excluded
      - --exclude=".git*"
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
}
      end

      it "should set capistrano configuration" do
        expect(@task).to receive(:set).at_least :once

        capture(:stdout) { @task.execute }
      end
    end

    context "when given a config missing required settings" do

      before do
        expect_any_instance_of(@config).to receive(:config)
          .at_least(:once).and_return YAML.load %Q{
deployment:
  rsync:
    scm: :git
    options:
      - --recursive
      - --delete
      - --delete-excluded
      - --exclude=".git*"
}
      end

      it "should raise error" do
        allow(stdout).to receive :print
        expect { @task.execute }.to raise_error SystemExit
      end
    end

    context "when given a config missing optional settings" do

        before do
          expect_any_instance_of(@config).to receive(:config)
            .at_least(:once).and_return YAML.load %Q{
deployment:
  application:
    name: example-app
  repository:
    repo_url: git@github.com:example/repo.git
    branch: :master
    scm: :rsync
  settings:
    keep_releases: 5
    use_sudo: false
}
        end

      it "should not raise error" do
        allow(stdout).to receive :print
        expect { @task.execute }.to_not raise_error
      end
    end
  end
end
