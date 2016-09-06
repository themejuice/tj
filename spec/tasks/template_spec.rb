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
    # expect_any_instance_of(@config).to receive(:config)
    #   .at_least(:once).and_return YAML.load %Q{
    File.open "#{@project.location}/Juicefile", "w+" do |f|
      f << %Q{
project:
  name: <%= name %>
  url: <%= url %>
commands:
  install:
    - "Installing template..."
    - "Done!"
deployment:
  stages:
    vagrant:
      server: <%= vm_ip %>
      path: <%= vm_srv %>
      domain: <%= url %>
}
    end
    expect_any_instance_of(@project).to receive(:to_h)
      .at_least(1).times.and_return({
        name: "parse-test",
        url: "parse-test.dev",
        vm_srv: "/srv/www/tj-parse-test"
      })
    expect_any_instance_of(@env).to receive(:to_h)
      .at_least(1).times.and_return({
        vm_ip: "192.168.13.37"
      })

    FileUtils.mkdir_p "#{@env.vm_path}"
  end

  before :each do
    @task = ThemeJuice::Tasks::Template.new
  end

  after :each do
    @config.instance_variable_set "@config", nil # ¯\_(ツ)_/¯
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

    it "should parse ERB template strings within the config" do
      capture(:stdout) { @task.execute }
      expect(@config.project).to eq({
        "name" => "parse-test",
        "url" => "parse-test.dev"
      })
      expect(@config.deployment).to eq({
        "stages" => {
          "vagrant" => {
            "server" => "192.168.13.37",
            "path" => "/srv/www/tj-parse-test",
            "domain" => "parse-test.dev"
          }
        }
      })
    end

    it "should replace current config with parsed config" do
      capture(:stdout) { @task.execute }
      expect(File.binread("#{@project.location}/Juicefile")).to eq %Q{
project:
  name: parse-test
  url: parse-test.dev
commands:
  install:
    - "Installing template..."
    - "Done!"
deployment:
  stages:
    vagrant:
      server: 192.168.13.37
      path: /srv/www/tj-parse-test
      domain: parse-test.dev
}
    end

    context "when Project.template_revision is nil" do

      before do
        allow(@project).to receive(:template_revision).and_return nil
      end

      it "should clone the master branch of the template repository" do
        output = capture(:stdout) { @task.execute }

        expect(output).to match /git clone/
        expect(output).to_not match /--branch 'sha1-rev'/
        expect(output).to match /#{@project.template}/
      end
    end

    context "when Project.template_revision is not nil" do

      before do
        allow(@project).to receive(:template_revision).and_return "sha1-rev"
      end

      it "should clone the master branch of the template repository" do
        output = capture(:stdout) { @task.execute }

        expect(output).to match /git clone/
        expect(output).to match /--branch 'sha1-rev'/
        expect(output).to match /#{@project.template}/
      end
    end
  end
end
