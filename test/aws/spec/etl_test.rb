# frozen_string_literal: true

require 'fileutils'
require 'pathname'

SEP = File::SEPARATOR
DBL_RELATIVE = '..' + SEP + '..' + SEP
TRPL_RELATIVE = DBL_RELATIVE + '..' + SEP

require_relative DBL_RELATIVE + 'test_helper'

require_relative TRPL_RELATIVE +
                 SEP +
                 'lib' +
                 SEP +
                 'spec_rb_transformer'

# Unit tests for the transformer
class EtlTest < Minitest::Test

  TEST_DIRECTORY = TRPL_RELATIVE + 'test' + SEP
  SEARCH_DIRECTORY = File.absolute_path(
    File.join(File.dirname(__FILE__), TEST_DIRECTORY + 'test_input')
  )
  TARGET_DIRECTORY = File.absolute_path(
    File.join(File.dirname(__FILE__), TEST_DIRECTORY + 'test_output')
  )
  EXPECTED_DIRECTORY = File.absolute_path(
    File.join(File.dirname(__FILE__), TEST_DIRECTORY + 'test_expected')
  )
  EXPECTED_DIRS = %w[
    ec2_tests_non_prod
    elbs_tests_non_prod
    nacl_buckets_tests_non_prod
    s3_buckets_tests_non_prod
    security_groups_tests_non_prod
  ].freeze

  def test_that_it_has_a_version_number
    refute_nil ::Aws::Spec::Etl::VERSION
  end

  def test_etl_transforms_generated_tests
    @spec_rb_transformer = SpecRbTransformer.new(
      SEARCH_DIRECTORY,
      TARGET_DIRECTORY
    )
    @spec_rb_transformer.transform

    output_dirs = Pathname(TARGET_DIRECTORY).children.select(&:directory?)

    # No unexpected dirs
    output_dirs.each do |dir|
      assert_includes(
        EXPECTED_DIRS, File.basename(dir),
        "Unexpected directory (#{dir})"
      )
    end

    # Expected number of dirs
    assert_equal(EXPECTED_DIRS.size, output_dirs.size)

    # Files as expected
    output_dirs.each do |dir|
      actual = dir.to_s + SEP + Dir.entries(dir)[2]
      sub_dir = dir.to_s.split(SEP)[(dir.to_s.split(SEP).size) -1]
      expected = EXPECTED_DIRECTORY + SEP + sub_dir + SEP + File.basename(actual)
      assert(FileUtils.compare_file(actual, expected))
    end
  end
end
