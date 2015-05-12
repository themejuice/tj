describe ThemeJuice::Tasks::Database do
  include FakeFS::SpecHelpers

  before do
    allow(ThemeJuice::Project).to receive(:name).and_return "project"
    allow(ThemeJuice::Project).to receive(:db_host).and_return "db_host"
    allow(ThemeJuice::Project).to receive(:db_name).and_return "db_name"
    allow(ThemeJuice::Project).to receive(:db_user).and_return "db_user"
    allow(ThemeJuice::Project).to receive(:db_pass).and_return "db_pass"
  end

  before :each do
    @task = ThemeJuice::Tasks::Database.new
  end

  describe "#execute" do
  end

  describe "#unexecute" do
  end
end
