# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path(DBL_RELATIVE + 'lib', __FILE__)
require 'aws/spec/etl'
require 'minitest/autorun'