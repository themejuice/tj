describe ThemeJuice::Tasks::WPConfig do

  before do
    @env = ThemeJuice::Env
    @project = ThemeJuice::Project

    allow(@env).to receive(:vm_path).and_return File.expand_path("~/tj-vagrant-test")
    allow(@env).to receive(:vm_ip).and_return "1.1.1.1"
    allow(@env).to receive(:no_landrush).and_return false
    allow(@env).to receive(:verbose).and_return true

    allow(@project).to receive(:location).and_return "#{@env.vm_path}/www/test"
    allow(@project).to receive(:db_host).and_return "test_db_host"
    allow(@project).to receive(:db_name).and_return "test_db_name"
    allow(@project).to receive(:db_user).and_return "test_db_user"
    allow(@project).to receive(:db_pass).and_return "test_db_pass"

    FileUtils.mkdir_p "#{@env.vm_path}/www/test"
  end

  before :each do
    @task = ThemeJuice::Tasks::WPConfig.new
    @config_file = "#{@project.location}/wp-config.php"
    @sample_file = "#{@project.location}/wp-config-sample.php"
    @test_contents = %Q{
define('DB_HOST', 'default_db_host');
define('DB_NAME', 'default_db_name'); // Weird side-hug comment
define('DB_USER', 'default_db_user');
// Testing comments
define('DB_PASSWORD', 'default_db_pass');
/* Stuff */
define('WP_DEBUG', false);
}
  end

  describe "#execute" do

    context "when Project.wp_config_modify and Project.no_env are true" do

      before do
        allow(@project).to receive(:wp_config_modify).and_return true
        allow(@project).to receive(:no_env).and_return true
      end

      context "when a wp-config file does not exist but a sample file does" do

        before do
          File.open(@sample_file, "w+") { |f| f << @test_contents }
        end

        it "should create a new wp-config file from the sample" do
          expect(thor_stdin).to_not receive(:readline)

          output = capture(:stdout) { @task.execute }

          expect(File.exist?(@config_file)).to be true
          expect(File.binread(@config_file)).to include "define('DB_HOST', 'test_db_host');"
          expect(File.binread(@config_file)).to include "define('DB_NAME', 'test_db_name');"
          expect(File.binread(@config_file)).to include "define('DB_USER', 'test_db_user');"
          expect(File.binread(@config_file)).to include "define('DB_PASSWORD', 'test_db_pass');"

          expect(output).to match /create/
        end
      end

      context "when a wp-config file does exist" do

        before do
          File.open(@config_file, "w+") { |f| f << @test_contents }
        end

        it "should modify the wp-config file when 'Y' is passed" do
          expect(thor_stdin).to receive(:readline).with(kind_of(String),
            kind_of(Hash)).once.and_return "Y"

          output = capture(:stdout) { @task.execute }

          expect(File.binread(@config_file)).to include "define('DB_HOST', 'test_db_host');"
          expect(File.binread(@config_file)).to include "define('DB_NAME', 'test_db_name');"
          expect(File.binread(@config_file)).to include "define('DB_USER', 'test_db_user');"
          expect(File.binread(@config_file)).to include "define('DB_PASSWORD', 'test_db_pass');"

          expect(output).to match /gsub/
        end

        it "should not modify the wp-config file when 'n' is passed" do
          expect(thor_stdin).to receive(:readline).with(kind_of(String),
            kind_of(Hash)).once.and_return "n"

          output = capture(:stdout) { @task.execute }

          expect(File.binread(@config_file)).to_not include "define('DB_HOST', 'test_db_host');"
          expect(File.binread(@config_file)).to_not include "define('DB_NAME', 'test_db_name');"
          expect(File.binread(@config_file)).to_not include "define('DB_USER', 'test_db_user');"
          expect(File.binread(@config_file)).to_not include "define('DB_PASSWORD', 'test_db_pass');"

          expect(File.exist?(@config_file)).to be true
        end
      end

      context "when the wp-config file and the sample file do not exist" do
        it "should throw an error and exit" do
          expect(stdout).to receive(:print).at_least(1).times
          expect { @task.execute }.to raise_error SystemExit
        end
      end
    end

    context "when Project.no_wp is true" do

      before do
        allow(@project).to receive(:wp_config_modify).and_return true
        allow(@project).to receive(:no_env).and_return true
        allow(@project).to receive(:no_wp).and_return true
      end

      context "when a wp-config file does not exist" do
        it "should not create wp-config file" do
          output = capture(:stdout) { @task.execute }

          expect(File.exist?(@config_file)).to be false
        end
      end

      context "when a wp-config file does exist" do

        before do
          FileUtils.touch @config_file
        end

        it "should not modify wp-config file" do
          output = capture(:stdout) { @task.execute }

          expect(File.exist?(@config_file)).to be true

          expect(output).to_not match /gsub/
        end
      end
    end

    context "when Project.no_db is true" do

      before do
        allow(@project).to receive(:wp_config_modify).and_return true
        allow(@project).to receive(:no_env).and_return true
        allow(@project).to receive(:no_db).and_return true
      end

      context "when a wp-config file does not exist" do
        it "should not create wp-config file" do
          output = capture(:stdout) { @task.execute }

          expect(File.exist?(@config_file)).to be false
        end
      end

      context "when a wp-config file does exist" do

        before do
          FileUtils.touch @config_file
        end

        it "should not modify wp-config file" do
          output = capture(:stdout) { @task.execute }

          expect(File.exist?(@config_file)).to be true

          expect(output).to_not match /gsub/
        end
      end
    end

    context "when Project.no_env is false" do

      before do
        allow(@project).to receive(:wp_config_modify).and_return false
        allow(@project).to receive(:no_env).and_return false
      end

      context "when a wp-config file does not exist" do
        it "should not create wp-config file" do
          output = capture(:stdout) { @task.execute }

          expect(File.exist?(@config_file)).to be false
        end
      end

      context "when a wp-config file does exist" do

        before do
          FileUtils.touch @config_file
        end

        it "should not modify wp-config file" do
          output = capture(:stdout) { @task.execute }

          expect(File.exist?(@config_file)).to be true

          expect(output).to_not match /gsub/
        end
      end
    end
  end
end
