# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2015, Sebastian Staudt

require 'open-uri'

require 'multi_xml'

module SteamCondenser::Community

  # This class provides basic functionality to parse XML data
  #
  # @author Sebastian Staudt
  module XMLData

    # Parse the given URL as XML data using `multi_xml`
    #
    # @param [String] url The URL to parse
    # @return [Hash<String, Object>] The data parsed from the XML document
    # @raise [Error] if an error occurs while parsing the XML data
    def parse(url)
      data = open url, proxy: true
      @xml_data = MultiXml.parse(data).values.first
    rescue
      raise SteamCondenser::Error.new "XML data could not be parsed: #{$!.message}", $!
    end

  end
end
