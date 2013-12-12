require 'test_helper'


describe Fuci::Kochiku::Server do
  before do
    @base = "http://kochiku-server-41925.phx-os1.stratus.dev.ebay.com"
    @server = Fuci::Kochiku::Server.new
    @tester = Fuci::Kochiku::Tester.new
  end

  # def test_uri (path)
  #   "#{@base}/#{path}"
  # end

  # it "triggers a build" do
  #   FakeWeb.register_uri(:post, test_uri("/projects/cm22222/builds"),
  #                        :response => File.read("./spec/fixtures/trigger_build_response"))
  #   response = @server.build
  #   assert_equal "example.com/build/id", response['location']
  #   # TODO: assert that we actually write to a file too....
  # end

  # it "gets the build status" do
  #   FakeWeb.register_uri(:post, test_uri
  # end

  # it "gets the build log" do
    
  # end

  # it "triggers a rebuild" do
  #   @server.last_build = "http://example/build/id"
  #   FakwWeb.register_url(:post, "http://example/build/id"
  #                        :response => File.read("./spec/fixtures/trigger_build_response"))
  #   response = @server.rebuild
  #   assert response['location']
  # end



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
