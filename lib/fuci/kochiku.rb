require 'fuci'
require 'fuci/configurable'
require 'fuci/git'
require 'httparty'

module Fuci

  def self.remote_build?
    File.exists?("/tmp/kochiku-last-build")
  end

  def self.remote_build_uri
    File.read(build_file)
  end

  def self.run
    if remote_build?
      puts "Found remote build..."
      # @server = Fuci::Kochiku::Server.new(remote_build_url)
      # @tester = Fuci::Kochiku::Tester.new
      # log = @server.fetch_log
      # if @tester.indicates_failure? log
      #   puts @tester.command log
      # else
      #   puts "Remote build passed. Yipee"
      # end
    else
      puts "Triggering build on kochiku..."
      @server = Fuci::Kochiku::Server.new(nil)
      @server.build
    end
  end

  module Kochiku
    class Server
      include HTTParty
      include Fuci::Git

      KOCHIKU_BASE = "http://kochiku-server-41925.phx-os1.stratus.dev.ebay.com"

      attr_accessor :last_build

      def initialize(last_build)
        @last_build = last_build
      end

      def repo_url
        `git config --get remote.origin.url`.strip
      end

      def hostname
        `hostname`.strip.sub(/\..*/, '')
      end

      def build_options
        {
          :body => {
            :build => {
              :hostname => hostname,
              :ref => current_branch_name,
              'auto_merge' => true,
              'repo_url' => repo_url,
              :target_name => "yolo-target"
            }
          }
        }
      end

      def build_status
        raise NotImplementedYet
      end

      def test_stdout_uri (build, part, attempt)
        "#{KOCHIKU_BASE}/log_files/cm22222/build_#{build}/part_#{part}/attempt_#{attempt}/stdout.log.gz"
      end

      def fetch_log
        resp = JSON.parse(self.class.get @last_build)

        stdouts = resp['build']['build_parts'].collect do |part|
          attempt = part['last_build_attempt']
          stdout_uri = test_stdout_uri(resp['build']['id'], part['id'], attempt['id'])
          if attempt['state'] != 'success'
            response = self.class.get(stdout_uri)
            response.body
          end
        end.compact

        stdouts.collect do |log|
          Zlib::GzipReader.new(StringIO.new(log)).read
        end.join("\n")
      end

      def build
        puts "triggering build: #{build_options}"
        resp = self.class.post "#{KOCHIKU_BASE}/projects/cm22222/builds", build_options
        File.open('/tmp/kochiku-last-build', 'w') do |f|
          @last_build = resp['location']
          f.write @last_build
        end
        resp
      end

      def rebuild
      end

      def build_status
        :red
      end
    end

    class Tester

      # must return a boolean telling whether the
      # log passed in indicates a failure made by
      # the tester
      def indicates_failure? log
        true
      end

      # must return a command string to be executed
      # by the system, e.g.
      # "rspec ./spec/features/it_is_cool_spec.rb"
      def command log
        test_command=""

        log.scan(/^.*#([^\n]*)\n.*\#\ \.([^\n]*)\:/m).each do |data|
           test_command+="spec " if test_command.empty?
           test_command+=".#{data[1]},"
        end

        log.scan(/^.*#(\w+)\s?\[(.*)\]/).each do |data|
          test_command+="ruby -Itest #{data[0]} -n #{data[1]};"
        end

        test_command
      end
    end
  end

  configure do |fu|
    fu.server = ::Fuci::Kochiku::Server
  end

end
