describe ThemeJuice::Command do

  before :each do
    @command = ThemeJuice::Command.new
  end

  describe "#execute" do
    it "should execute each command in tasks array" do
      task = double "task", :execute => nil

      @command.runner { |tasks| tasks << task }
      @command.execute

      expect(task).to have_received :execute
    end
  end

  describe "#unexecute" do
    it "should unexecute each command in tasks array" do
      task = double "task", :unexecute => nil

      @command.runner { |tasks| tasks << task }
      @command.unexecute

      expect(task).to have_received :unexecute
    end
  end
end
