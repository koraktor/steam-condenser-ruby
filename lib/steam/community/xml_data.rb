# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'open-uri'

require 'multi_xml'

module XMLData

  def parse(url)
    data = open(url, { :proxy => true })
    @xml_data = MultiXml.parse(data).values.first
  end

end
