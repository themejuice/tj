describe ThemeJuice::Tasks::Entry do

  before do
    @env     = ThemeJuice::Env
    @project = ThemeJuice::Project
    
    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant")
    allow(@env).to receive(:dryrun).and_return true
    
    FakeFS::FileSystem.clone "#{@env.vm_path}/database"
  end

  before :each do
    @task = ThemeJuice::Tasks::Entry.new
  end
  
  it { is_expected.to respond_to :entry }

  describe "#entry_file_is_setup?" do
    
    it "should return true if file exists" do
      @task.entry = {
        :file => "#{@env.vm_path}/database/init-custom.sql"
      }
      expect(@task.send(:entry_file_is_setup?)).to be true
    end
    
    it "should return false if file does not exist" do
      @task.entry = {
        :file => "unknown.txt"
      }
      expect(@task.send(:entry_file_is_setup?)).to be false
    end
  end

  describe "#create_entry_file" do
    
    it "should create entry file if it does not exist" do
      capture(:stdout) do
        expect_any_instance_of(ThemeJuice::Util).to receive :create_file
        @task.entry = {
          :file => "a-test-file.txt",
          :name => "test"
        }
        expect { @task.send(:create_entry_file) }.to output.to_stdout
      end
    end
    
    it "should not create entry file if it already exists" do
      capture(:stdout) do
        expect_any_instance_of(ThemeJuice::Util).not_to receive :create_file
        @task.entry = {
          :file => "#{@env.vm_path}/database/init-custom.sql",
          :name => "test" }
        expect { @task.send(:create_entry_file) }.not_to output.to_stdout
      end
    end
  end

  describe "#entry_is_setup?" do
    
    it "should return true if file exists" do

    end
    
    it "should return false if file does not exist" do

    end
  end

  describe "#create_entry" do
    it "should append to file" do
      # expect(File).to receive(:open).with any_args
      # 
      # output = capture(:stdout) { @task.execute }
      # 
      # expect(output).not_to match /gsub/
    end
  end

  describe "#remove_entry" do
    it "should gsub file" do
      # expect(File).to receive(:open).with any_args
      # 
      # output = capture(:stdout) { @task.unexecute }
      # 
      # expect(output).not_to match /gsub/
    end
  end
end
