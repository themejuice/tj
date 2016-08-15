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
  it { is_expected.to respond_to :vm_revision }
  it { is_expected.to respond_to :vm_revision= }
  it { is_expected.to respond_to :from_path }
  it { is_expected.to respond_to :from_path= }
  it { is_expected.to respond_to :from_srv }
  it { is_expected.to respond_to :from_srv= }
  it { is_expected.to respond_to :inside_vm }
  it { is_expected.to respond_to :inside_vm= }
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
  it { is_expected.to respond_to :quiet }
  it { is_expected.to respond_to :quiet= }
  it { is_expected.to respond_to :robot }
  it { is_expected.to respond_to :robot= }
  it { is_expected.to respond_to :trace }
  it { is_expected.to respond_to :trace= }
  it { is_expected.to respond_to :dryrun }
  it { is_expected.to respond_to :dryrun= }
  it { is_expected.to respond_to :stage }
  it { is_expected.to respond_to :stage= }
  it { is_expected.to respond_to :cap }
  it { is_expected.to respond_to :cap= }
  it { is_expected.to respond_to :archive }
  it { is_expected.to respond_to :archive= }
  it { is_expected.to respond_to :branch }
  it { is_expected.to respond_to :branch= }

  describe ".inspect" do
    it "should return an array of all instance variables" do
      expect(@env.inspect).to be_a Array
    end
  end

  %W[vm_box vm_path vm_ip vm_prefix].each do |prop|
    describe ".#{prop}" do

      it "should expect to use the set value" do
        @env.send "#{prop}=", "test"
        expect(@env.send(prop)).to eq "test"
      end

      it "should expect to use the default value" do
        @env.send "#{prop}=", nil
        expect(@env.send(prop)).to be_a String
      end
    end
  end

  %W[boring yolo no_unicode no_colors no_animations no_landrush no_port_forward
    robot nginx verbose quiet trace dryrun].each do |prop|
    describe ".#{prop}" do

      it "should expect to use the set boolean value" do
        @env.send "#{prop}=", true
        expect(@env.send(prop)).to eq true
      end

      it "should expect to use the default boolean value" do
        @env.send "#{prop}=", nil
        expect(@env.send(prop)).to eq false
      end
    end
  end
end
