require 'open-uri'

module SteamCondenser::Community
  module URI
    if RUBY_VERSION >= '2.7.0'
      def self.open(*args)
        ::URI.open(*args)
      end
    else
      def self.open(*args)
        Kernel.open(*args)
      end
    end
  end
end
