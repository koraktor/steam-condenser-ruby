# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'open-uri'

require 'multi_xml'

# This class provides basic functionality to parse XML data
#
# @author Sebastian Staudt
module XMLData

  # Parse the given URL as XML data using `multi_xml`
  #
  # @param [String] url The URL to parse
  # @return [Hash<String, Object>] The data parsed from the XML document
  def parse(url)
    data = open(url, { :proxy => true })
    @xml_data = MultiXml.parse(data).values.first
  end

end
