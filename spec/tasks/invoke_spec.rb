describe ThemeJuice::Tasks::Invoke do

  before do
    @env = ThemeJuice::Env
    @config = ThemeJuice::Config
    allow(@env).to receive(:stage).and_return "staging"
  end

  before :each do
    @task = ThemeJuice::Tasks::Invoke
  end

  describe "#execute" do

    context "when called with no arguments" do
      it "should invoke a deployment" do
        expect(@env.cap).to receive(:invoke).with "deploy"

        capture(:stdout) { @task.new.execute }
      end
    end

    context "when called with the 'rollback' argument" do
      it "should invoke a rollback" do
        expect(@env.cap).to receive(:invoke).with "deploy:rollback"

        capture(:stdout) { @task.new(["rollback"]).execute }
      end
    end

    context "when called with any other arguments" do
      it "should invoke with passed arguments" do
        expect(@env.cap).to receive(:invoke).with "a:task"

        capture(:stdout) { @task.new(["a:task"]).execute }
      end

      it "should invoke with passed arguments" do
        expect(@env.cap).to receive(:invoke).with "another:task", "--flag"

        capture(:stdout) { @task.new(["another:task", "--flag"]).execute }
      end
    end
  end
end
