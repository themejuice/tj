describe ThemeJuice::Project do

  before do
    @project = ThemeJuice::Project
  end

  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :location }
  it { is_expected.to respond_to :url }
  it { is_expected.to respond_to :xip_url }
  it { is_expected.to respond_to :template }
  it { is_expected.to respond_to :vm_root }
  it { is_expected.to respond_to :vm_location }
  it { is_expected.to respond_to :vm_srv }
  it { is_expected.to respond_to :vm_restart }
  it { is_expected.to respond_to :repository }
  it { is_expected.to respond_to :db_host }
  it { is_expected.to respond_to :db_name }
  it { is_expected.to respond_to :db_user }
  it { is_expected.to respond_to :db_pass }
  it { is_expected.to respond_to :db_import }
  it { is_expected.to respond_to :db_drop }
  it { is_expected.to respond_to :bare }
  it { is_expected.to respond_to :skip_repo }
  it { is_expected.to respond_to :skip_db }
  it { is_expected.to respond_to :use_defaults }
  it { is_expected.to respond_to :no_wp }
  it { is_expected.to respond_to :no_db }

  describe ".inspect" do
    it "should return an array of all instance variables" do
      expect(@project.inspect).to be_a Array
    end
  end
end
