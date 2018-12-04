# frozen_string_literal: true

require 'pathname'

DOUBLE_OFFSET = '..' + File::SEPARATOR + '..' + File::SEPARATOR
TRIPLE_OFFSET = DOUBLE_OFFSET + '..' + File::SEPARATOR

require_relative DOUBLE_OFFSET + 'test_helper'

require_relative TRIPLE_OFFSET +
                 File::SEPARATOR +
                 'lib' +
                 File::SEPARATOR +
                 'spec_rb_transformer'

# Unit tests for the transformer
class EtlTest < Minitest::Test

  TEST_DIRECTORY = TRIPLE_OFFSET + 'test' + File::SEPARATOR
  SEARCH_DIRECTORY = File.absolute_path(
    File.join(File.dirname(__FILE__), TEST_DIRECTORY + 'test_input')
  )
  TARGET_DIRECTORY = File.absolute_path(
    File.join(File.dirname(__FILE__), TEST_DIRECTORY + 'test_output')
  )
  EXPECTED_DIRECTORY = File.absolute_path(
    File.join(File.dirname(__FILE__), TEST_DIRECTORY + 'test_expected')
  )

  def test_that_it_has_a_version_number
    refute_nil ::Aws::Spec::Etl::VERSION
  end

  def test_etl_transforms_generated_tests
    @spec_rb_transformer = SpecRbTransformer.new(
      SEARCH_DIRECTORY,
      TARGET_DIRECTORY
    )
    @spec_rb_transformer.transform

    expected_dirs = %w[
      ec2_tests_non_prod
      elbs_tests_non_prod
      nacl_buckets_tests_non_prod
      s3_buckets_tests_non_prod
      security_groups_tests_non_prod
    ]
    output_dirs = Pathname(EXPECTED_DIRECTORY).children.select(&:directory?)

    # No unexpected dirs
    output_dirs.each do |dir|
      assert_includes(
        expected_dirs, File.basename(dir),
        "Unexpected directory (#{dir})"
      )
    end

    # Expected number of dirs
    assert_equal(expected_dirs.size, output_dirs.size)

  end
end