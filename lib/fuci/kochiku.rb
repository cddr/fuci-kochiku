require 'fuci'
require 'fuci/configurable'

module Fuci
  module Kochiku
    class Server
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
