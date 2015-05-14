describe ThemeJuice::Tasks::Database do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/vagrant")
    allow(@env).to receive(:dryrun).and_return true
    allow(@project).to receive(:name).and_return "project"
    allow(@project).to receive(:db_host).and_return "db_host"
    allow(@project).to receive(:db_name).and_return "db_name"
    allow(@project).to receive(:db_user).and_return "db_user"
    allow(@project).to receive(:db_pass).and_return "db_pass"
  end

  before :each do
    @task = ThemeJuice::Tasks::Database.new
  end

  describe "#execute" do
    # Handled in entry_spec.rb
  end

  describe "#unexecute" do

    it "should gsub custom database file" do
      # Handled in entry_spec.rb
    end

    context "when Project#db_drop is set to true" do

      before do
        allow(@project).to receive(:db_drop).and_return true
      end

      it "should drop database when 'Y' is passed" do

        expect(thor_stdin).to receive(:readline).with(kind_of(String),
          kind_of(Hash)).once.and_return "Y"

        output = capture(:stdout) { @task.unexecute }

        expect(output).to match /drop/
      end

      it "should not drop database when 'n' is passed" do
        expect(thor_stdin).to receive(:readline).with(kind_of(String),
          kind_of(Hash)).once.and_return "n"

        output = capture(:stdout) { @task.unexecute }

        expect(output).not_to match /drop/
      end
    end

    context "when Project#db_drop is set to false" do

      before do
        allow(@project).to receive(:db_drop).and_return false
      end

      it "should not prompt to drop database" do
        expect(thor_stdin).not_to receive(:readline).with(kind_of(String),
          kind_of(Hash))

        expect { @task.unexecute }.not_to output(/drop/).to_stdout
      end
    end
  end
end
