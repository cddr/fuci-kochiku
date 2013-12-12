require 'fuci'
require 'fuci/configurable'
require 'fuci/git'
require 'httparty'
require 'libarchive'

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
        puts log
        Zlib::GzipReader.open(log) do |gz|
          gz.each_line do |line|
            puts line
          end
        end
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
