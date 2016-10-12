describe ThemeJuice::Migrations::ForwardPorts do

  before do
    @env = ThemeJuice::Env

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:verbose).and_return true

    FileUtils.mkdir_p "#{@env.vm_path}"
    FileUtils.touch "#{@env.vm_path}/Customfile"
  end

  before :each do
    @migration = ThemeJuice::Migrations::ForwardPorts.new
    @file = "#{@env.vm_path}/Customfile"
  end

  describe "#execute" do

    context "when customfile contains an outdated entry" do

      before do
        File.open(@file, "w+") { |f| f << @migration.send(:old_content) }
      end

      it "should migrate the port forwarding entries to new content" do
        expect(@migration).to receive(:replace_content)

        capture(:stdout) { @migration.execute }
      end
    end

    context "when customfile does not contain an outdated entry" do

      before do
        File.open(@file, "w+") { |f| f << @migration.send(:new_content) }
      end

      it "should not migrate the port forwarding entries" do
        expect(@migration).to_not receive(:replace_content)

        capture(:stdout) { @migration.execute }
      end
    end

    context "when customfile does not exist" do

      before do
        File.unlink @file
      end

      it "should not throw an error" do
        expect(@migration).to_not receive(:replace_content)

        expect { @migration.execute }.to_not raise_error
      end

      it "should not migrate the port forwarding entries" do
        expect(@migration).to_not receive(:replace_content)

        capture(:stdout) { @migration.execute }
      end
    end
  end
end
