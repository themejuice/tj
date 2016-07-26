describe ThemeJuice::Tasks::VMProvision do

  before do
    @env     = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@env).to receive(:quiet).and_return false
    allow(@env).to receive(:dryrun).and_return true
    allow_any_instance_of(ThemeJuice::Util).to receive(:run)
      .with([]).and_call_original
    allow_any_instance_of(ThemeJuice::Util).to receive(:run)
      .with("vagrant status --machine-readable", kind_of(Hash))
      .and_return "test..."
  end

  before :each do
    @task = ThemeJuice::Tasks::VMProvision.new
  end

  describe "#execute" do

    before do
      allow(@project).to receive(:vm_provision).and_return true
    end

    it "should provision vagrant" do
      output = capture(:stdout) { @task.execute }

      expect(output).to match /vagrant up --provision/
    end

    context "when the vagrant box is currently running" do

      before do
        allow_any_instance_of(ThemeJuice::Util).to receive(:run)
          .with("vagrant status --machine-readable", kind_of(Hash))
          .and_return "running..."
      end

      it "should halt vagrant before provisioning" do
        output = capture(:stdout) { @task.execute }

        expect(output).to match /vagrant halt/
      end
    end

    context "when the vagrant box is not currently running" do
      it "should not halt vagrant before provisioning" do
        output = capture(:stdout) { @task.execute }

        expect(output).to_not match /vagrant halt/
      end
    end
  end

  describe "#unexecute" do
    it "should provision vagrant" do
      output = capture(:stdout) { @task.unexecute }

      expect(output).to match /vagrant up --provision/
    end
  end
end
