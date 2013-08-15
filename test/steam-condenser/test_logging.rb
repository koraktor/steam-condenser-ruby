# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2013, Sebastian Staudt

require 'helper'

class TestLogging < Test::Unit::TestCase

  class LoggingClass
    include Logging
  end

  def test_change_defaults
    Logging.formatter = formatter = ->(severity, time, progname, msg) { 'test' }
    Logging.level = Logger::Severity::DEBUG
    Logging.logdev = file = Tempfile.new('log')

    logger = LoggingClass.log

    assert_instance_of Logger, logger
    assert_equal formatter, logger.formatter
    assert_equal Logger::Severity::DEBUG, logger.level
    assert_equal file, logger.instance_variable_get(:@logdev).dev
    assert_equal 'TestLogging::LoggingClass', logger.progname
  end

  def test_default_logger
    logger = LoggingClass.log

    assert_instance_of Logger, logger
    assert_instance_of Logger::Formatter, logger.formatter
    assert_equal Logger::Severity::WARN, logger.level
    assert_equal STDOUT, logger.instance_variable_get(:@logdev).dev
    assert_equal 'TestLogging::LoggingClass', logger.progname
  end

  def test_log
    instance = LoggingClass.new

    assert_equal LoggingClass.log, instance.log
  end

  def teardown
    Logging.send :class_variable_set, :@@formatter, Logger::Formatter.new
    Logging.send :class_variable_set, :@@level, Logger::Severity::WARN
    Logging.send :class_variable_set, :@@logdev, STDOUT
    LoggingClass.send :class_variable_set, :@@logger, nil
  end

end
