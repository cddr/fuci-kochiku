require 'test_helper'


describe Fuci::Kochiku::Server do
  before do
    FakeWeb.allow_net_connect = false
    @base = "http://kochiku-server-41925.phx-os1.stratus.dev.ebay.com"
    @server = Fuci::Kochiku::Server.new
    @tester = Fuci::Kochiku::Tester.new
  end

  it ".build" do
    FakeWeb.register_uri(:post, test_uri("projects/cm22222/builds"),
                         :response => File.read("./spec/fixtures/trigger_build_response"))
    response = @server.build
    assert_equal "example.com/build/id", response['location']
    # TODO: assert that we actually write to a file too....
  end

  it ".fetch_log" do
    @server.last_build = "http://yolo/api/build/42"
    FakeWeb.register_uri(:get, "http://yolo/api/build/42",
                         :body => File.read("./spec/fixtures/build_response"))
    FakeWeb.register_uri(:get, @server.test_stdout_uri(18, 311, 364),
                         :body => IO.read("./spec/fixtures/stdout.success.log.gz"))
    FakeWeb.register_uri(:get, @server.test_stdout_uri(18, 312, 365),
                         :body => IO.read("./spec/fixtures/stdout.failure.log.gz"))

    expected = ["success", "failure"].collect do |log|
      Zlib::GzipReader.open("./spec/fixtures/stdout.#{log}.log.gz").read
    end.join("\n")

    assert_equal expected, @server.fetch_log
  end

  private
  def test_uri (path)
    "#{@base}/#{path}"
  end

  def gzipped_log_string(name)
    StringIO.new("", 'w') do |s|
      Zlib::GzipWriter.new(s) do |gz|
        gz.write File.open(name).read
      end
    end
  end

  it 'returns true when log indicates_failure?' do
    log = File.open('./spec/fixtures/fail.log.gz')
    assert_equal true, @tester.indicates_failure?(log.path)
  end

  it 'command returns test name and file name from minitest' do
    log = File.open('./spec/fixtures/minitest_fail.txt').read
    expected_test1 = "ruby -Itest test_shallow_clone_attributes -n /Users/Shared/Jenkins/Home/jobs/CM_Pull_Request_Builder/workspace/test/models/ad_distribution_test.rb:104;"
    expected_test2 = "ruby -Itest test_update_with_blank_line_item_id -n /Users/Shared/Jenkins/Home/jobs/CM_Pull_Request_Builder/workspace/test/integration/buy_item_api_test.rb:60;"
    results = @tester.command(log)
    assert_equal (expected_test1+expected_test2), results
  end

  it 'command returns test name and file name from rspec' do
    log = File.open('./spec/fixtures/spectest_fail.txt').read
    expected = "spec ./spec/controllers/build_artifacts_controller_spec.rb:18,"
    assert_equal expected, @tester.command(log)
  end


end
