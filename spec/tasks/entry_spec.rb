describe ThemeJuice::Tasks::Entry, :fakefs => true do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant")
    allow(@env).to receive(:dryrun).and_return true

    FakeFS::FileSystem.clone "#{@env.vm_path}/database"
  end

  before :each do
    @task = ThemeJuice::Tasks::Entry.new
  end

  describe "#entry_file_is_setup?" do
  end

  describe "#create_entry_file" do
  end

  describe "#entry_is_setup?" do
  end

  describe "#create_entry" do
  end

  describe "#remove_entry" do

    it "should gsub file" do
      # expect(File).to receive(:open).with any_args
      #
      # output = capture(:stdout) { @task.unexecute }
      #
      # expect(output).to match /gsub/
    end
  end
end
