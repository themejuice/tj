require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

lib = File.expand_path "../../../", __FILE__
$:.unshift lib unless $:.include? lib

# pp must be required before fakefs
# @see https://github.com/defunkt/fakefs/issues/99
require "pp"
require "fakefs/spec_helpers"
require "lib/theme-juice"

$0 = "tj"
ARGV.clear

# Fix issue where ENV variables set would cause tests to fail
ENV.keys.each { |k| ENV.delete(k) if /^tj_/i =~ k }

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
