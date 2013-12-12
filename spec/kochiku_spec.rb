require 'test_helper'

describe Fuci::Kochiku::Server do
  before do
#    FakeWeb.allow_net_connect = false
    @base = "http://kochiku-server-41925.phx-os1.stratus.dev.ebay.com"
    @server = Fuci::Kochiku::Server.new
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

  # it "triggers a rebuild" do
  #   @server.last_build = "http://example/build/id"
  #   FakwWeb.register_url(:post, "http://example/build/id"
  #                        :response => File.read("./spec/fixtures/trigger_build_response"))
  #   response = @server.rebuild
  #   assert response['location']
  # end
end
