require_relative "../lib/theme-juice"

describe ThemeJuice::Command do

  before do
    @command = ThemeJuice::Command.new
  end

  describe "#execute" do
    it "should execute each command in tasks array" do
      task = double("task")
      allow(task).to receive(:execute)

      @command.runner { |tasks| tasks << task }
      @command.execute

      expect(task).to have_received(:execute)
    end
  end

  describe "#unexecute" do
    it "should unexecute each command in tasks array" do
      task = double("task")
      allow(task).to receive(:unexecute)

      @command.runner { |tasks| tasks << task }
      @command.unexecute

      expect(task).to have_received(:unexecute)
    end
  end
end
