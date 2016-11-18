describe ThemeJuice::Tasks::List do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:vm_prefix).and_return "prefix-"
    allow(@project).to receive(:vm_root).and_return "#{@env.vm_path}/www"
    allow_any_instance_of(Kernel).to receive(:`).with(/vagrant/).and_return %Q{
vvv                       192.168.50.4
4.50.168.192.in-addr.arpa test4.dev
test1.dev                 192.168.50.4
test2.dev                 192.168.50.4
test3.dev                 192.168.50.4
test4.dev                 192.168.50.4
}

    FileUtils.mkdir_p "#{@env.vm_path}"
  end

  before :each do
    @task = ThemeJuice::Tasks::List.new
  end

  describe "#list" do

    it "should print all project names to $stdout" do
      expect { @task.list :projects }.to output.to_stdout
    end

    it "should print all project urls to $stdout" do
      expect { @task.list :urls }.to output.to_stdout
    end

    it "should raise error if prop does not exist" do
      allow(@env).to receive(:trace).and_return true
      expect(stdout).to receive :print
      expect { @task.list :prop }.to raise_error NotImplementedError
    end
  end

  describe "#projects" do

    before :each do
      FileUtils.mkdir_p "#{@project.vm_root}/prefix-test-1"
      FileUtils.mkdir_p "#{@project.vm_root}/prefix-test-2"
      FileUtils.mkdir_p "#{@project.vm_root}/prefix-prefix-test-3"
    end

    it "should return an array of project names" do
      expect(@task.projects).to be_a Array
    end

    it "should return an array that includes test projects" do
      expect(@task.projects).to include /test-1/
      expect(@task.projects).to include /test-2/
      expect(@task.projects).to include /prefix-test-3/
    end

    it "should return an array that does not include test projects" do
      expect(@task.projects).to_not include /test-4/
    end
  end

  describe "#urls" do

    it "should return an array of domain names" do
      expect(@task.urls).to be_a Array
    end

    it "should return an array that includes test domains" do
      expect(@task.urls).to include /test1\.dev/
      expect(@task.urls).to include /test2\.dev/
      expect(@task.urls).to include /test3\.dev/
      expect(@task.urls).to include /test4\.dev/
    end

    it "should return an array that does not include test domains" do
      expect(@task.urls).to_not include /test5\.dev/
    end
  end
end
