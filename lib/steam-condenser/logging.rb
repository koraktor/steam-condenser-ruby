# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2013, Sebastian Staudt

require 'logger'

module SteamCondenser

  # This module is included by all classes of Steam Condenser that log events
  #
  # It is a lightweight wrapper around Ruby's `Logger` class from the standard
  # library.
  module Logging

    @@formatter = Logger::Formatter.new

    @@level = Logger::Severity::WARN

    @@logdev = STDOUT

    # Creates a logger for the class that includes this module
    #
    # Additionally it defines a `.log` singleton method for the class that
    # includes this module
    #
    # @param [Class] klass The class that includes this module
    def self.included(klass)
      klass.send :class_variable_set, :@@logger, nil
      klass.define_singleton_method :log do
        logger = class_variable_get :@@logger
        if logger.nil?
          logger = Logger.new @@logdev
          logger.formatter = @@formatter
          logger.level = @@level
          logger.progname = klass.name

          class_variable_set :@@logger, logger
        end
        logger
      end
    end

    # Sets the default formatter to use for all logging events in Steam
    # Condenser
    #
    # @param [#call] formatter The formatter to use when logging
    def self.formatter=(formatter)
      @@formatter = formatter
    end

    # Sets the default logging device to use for all logging events in Steam
    # Condenser
    #
    # @param [IO] logdev For example an output stream or file to log to
    def self.logdev=(logdev)
      @@logdev = logdev
    end

    # Sets the default log level to use for filtering all logging events in
    # Steam Condenser
    #
    # @param [Fixum] level The log level to use when logging
    def self.level=(level)
      @@level = level
    end

    # Returns the logger for the current class
    #
    # @return [Logger] The logger for the current class
    def log
      self.class.log
    end

  end

end
