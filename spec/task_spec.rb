require_relative "../lib/theme-juice"

describe ThemeJuice::Task do

  before do
    @task = ThemeJuice::Task.new
  end

  describe "#runner" do
    it "yields to tasks array" do
      expect { |b| @task.runner(&b) }.to yield_control
    end
    it "should add task to tasks array" do
      @task.runner { |tasks| tasks << "a task" }
      expect(@task.tasks).to eq(["a task"])
    end
  end

  describe "#execute" do
    it "should raise unimplemented error" do
      expect { @task.execute }.to raise_error
    end
  end

  describe "#unexecute" do
    it "should raise unimplemented error" do
      expect { @task.unexecute }.to raise_error
    end
  end
end
