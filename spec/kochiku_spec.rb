require 'test_helper'

describe Fuci::Kochiku::Server do
  before do
    @base = "http://kochiku-server-41925.phx-os1.stratus.dev.ebay.com"
    @server = Fuci::Kochiku::Server.new
  end

  def test_uri (path)
    "#{@base}/#{path}"
  end

  it "triggers a build" do
    FakeWeb.register_uri(:post, test_uri("/projects/cm22222/builds"),
                         :response => File.read("./spec/fixtures/trigger_build_response"))
    response = @server.build
    assert_equal "example.com/build/id", response['location']
    # TODO: assert that we actually write to a file too....
  end

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
end
