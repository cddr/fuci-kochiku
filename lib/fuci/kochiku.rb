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

      def build
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

      def fetch_log
        "All tests passed!"
      end
    end
  end

  configure do |fu|
    fu.server = ::Fuci::Kochiku::Server
  end
end
