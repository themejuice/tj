describe ThemeJuice::Tasks::Location do

  before do
    @env     = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:verbose).and_return true
    allow(@project).to receive(:location).and_return "vm-location-test"
  end

  before :each do
    @task = ThemeJuice::Tasks::Location.new
  end

  describe "#execute" do
    it "should create the project location" do
      output = capture(:stdout) { @task.execute }

      expect(Dir.exist?(@project.location)).to be true

      expect(output).to match /create/
    end
  end
end
