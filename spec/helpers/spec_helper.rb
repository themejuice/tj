require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

lib = File.expand_path "../../lib/", __FILE__
$:.unshift lib unless $:.include? lib

require "fakefs/spec_helpers"
require "theme-juice"

$0 = "tj"
ARGV.clear

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval "$#{stream} = #{stream.upcase}"
    end
    result
  end

  def stdout
    $stdout
  end

  def stderr
    $stderr
  end

  def stdin
    $stdin
  end

  def thor_stdin
    Thor::LineEditor
  end
end
