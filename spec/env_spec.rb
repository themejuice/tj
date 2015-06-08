describe ThemeJuice::Env do

  before do
    @env = ThemeJuice::Env
  end
  
  it { is_expected.to respond_to :vm_box }
  it { is_expected.to respond_to :vm_box= }
  it { is_expected.to respond_to :vm_path }
  it { is_expected.to respond_to :vm_path= }
  it { is_expected.to respond_to :vm_ip }
  it { is_expected.to respond_to :vm_ip= }
  it { is_expected.to respond_to :vm_prefix }
  it { is_expected.to respond_to :vm_prefix= }
  it { is_expected.to respond_to :no_unicode }
  it { is_expected.to respond_to :no_unicode= }
  it { is_expected.to respond_to :no_colors }
  it { is_expected.to respond_to :no_colors= }
  it { is_expected.to respond_to :no_animations }
  it { is_expected.to respond_to :no_animations= }
  it { is_expected.to respond_to :no_landrush }
  it { is_expected.to respond_to :no_landrush= }
  it { is_expected.to respond_to :boring }
  it { is_expected.to respond_to :boring= }
  it { is_expected.to respond_to :yolo }
  it { is_expected.to respond_to :yolo= }
  it { is_expected.to respond_to :verbose }
  it { is_expected.to respond_to :verbose= }
  it { is_expected.to respond_to :dryrun }
  it { is_expected.to respond_to :dryrun= }

  describe "#inspect" do
    it "should return an array of all instance variables" do
      expect(@env.inspect).to be_a Array
    end
  end
end
