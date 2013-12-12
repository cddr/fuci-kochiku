require 'fuci'
require 'fuci/configurable'
require 'fuci/git'
require 'httparty'

module Fuci
  module Kochiku
    class Server
      include HTTParty
      include Fuci::Git

      KOCHIKU_BASE = "http://kochiku-server-41925.phx-os1.stratus.dev.ebay.com"

      attr_accessor :last_build

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
        resp = self.class.post "#{KOCHIKU_BASE}/projects/cm22222/builds", build_options
        File.open('/tmp/kochiku-last-build', 'w') do |f|
          @last_build = resp['location']
          f.write @last_build
        end
        resp
      end
    end
  end

  configure do |fu|
    fu.server = ::Fuci::Kochiku::Server
  end
end
