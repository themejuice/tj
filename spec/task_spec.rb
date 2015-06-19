describe ThemeJuice::Task do

  before do
    allow(ThemeJuice::Env).to receive(:verbose).and_return true
  end

  before :each do
    @task = ThemeJuice::Task.new
  end

  describe "#runner" do

    it "yields to tasks array" do
      expect { |b| @task.runner(&b) }.to yield_control
    end

    it "should add task to tasks array" do
      @task.runner { |tasks| tasks << "a task" }
      expect(@task.tasks).to eq ["a task"]
    end
  end

  describe "#execute" do
    it "should raise not implemented error" do
      expect(stdout).to receive(:print).with kind_of String
      expect { @task.execute }.to raise_error NotImplementedError
    end
  end

  describe "#unexecute" do
    it "should raise not implemented error" do
      expect(stdout).to receive(:print).with kind_of String
      expect { @task.unexecute }.to raise_error NotImplementedError
    end
  end
end
