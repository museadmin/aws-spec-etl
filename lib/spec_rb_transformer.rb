# frozen_string_literal: true
#
require 'active_support'
require 'active_support/core_ext'
require 'pathname'
require_relative 'file_sieve'
require_relative 'matches'


# Transform a generated spec.rb file for running
class SpecRbTransformer

  TEST_EXTENSION = '_spec.rb'
  REMOVALS = %w(blddev- bldinf- default)
  ENVIRONMENTS = %w(non_prod prod)

  def initialize(search_directory, target_root_directory)
    @target_root_directory = File.absolute_path(target_root_directory) + File::SEPARATOR
    @sieve = FileSieve.new(search_directory, TEST_EXTENSION)
    @tag = ''
    @described = false
  end

  # Clear out the last run
  def clear_last_run(root_dir)
    Pathname.new(root_dir).children.select { |c| c.directory? }.collect { |p| p.to_s }.each do |dir|
      next unless dir.include?("_tests_")
      puts "Deleting directory from previous run #{dir}"
      FileUtils.remove_dir(dir)
    end
  end

  def transform
    @sieve.found_files.each {|file|
      parse_environment_tag_from_test_file(file)
      basename = File.basename(file)
      type = parse_object_type_from_file_name(basename)
      account = parse_account_from_context_line(file)
      target_file = setup_generator_output(type, account, basename)

      File.delete(target_file) if File.exist?(target_file)
      @describe = false

      File.open(target_file, 'w') do |wr|
        File.foreach(file) do |line|
          line = transform_line(line)
          wr.write(line)
        end
      end

      clean_end_of_file(target_file)
      REMOVALS.each {|pattern| delete_test_block(pattern, target_file)}

      File.delete(target_file) unless @described
    }
  end

  # Sort out indentation of last end statement
  def clean_end_of_file(file)
    lines = File.readlines(file)
    (lines.length - 1).step(0, -1) do |i|
      if lines[i] == "  end\n"
        lines[i] = "end\n"
        break
      end
    end

    File.open(file, 'w') do |f|
      lines.each do |line|
        f.write(line)
      end
    end
  end

  # Create the context description
  def construct_test_context(basename)
    vpc = basename.split('_')[2]
    partition = basename.split('_')[0].to_s.upcase
    partition + ' Tests on ' + vpc
  end

  # Delete an entire test block if the description matches the pattern
  def delete_test_block(pattern, file)
    lines = File.readlines(file)
    remove = false
    File.delete(file)
    File.open(file, 'w') do |f|
      lines.each do |line|
        remove = true if line.include?('describe ') && line.include?(pattern)
        if remove
          remove = false if line.include?('  end')
          next
        end
        f.write(line)
      end
    end
  end

  # Insert the dynamic_resource call
  def insert_dynamic_resource(line)
    line.insert(line.index('(') + 1, 'dynamic_resource(')
    line.insert(line.index(')'), ')')
    line
  end

  # Insert any tags
  def insert_environment_tag(line)
    line = line.slice(0, line.index(' do'))
    line + @tag + ' do' + "\n"
  end

  # Parse the account (prod / non_prod) from the context line of a test
  def parse_account_from_context_line(file)
    File.readlines(file).each do |line|
      ENVIRONMENTS.each {|env| return env if line.include?(env)}
    end
    raise(RuntimeError, 'Failed to find account from context line in file (' + file + ')')
  end

  # What environment referenced in file
  def parse_environment_tag_from_test_file(file)
    File.foreach(file) do |line|
      if line.include?('describe')
        set_environment_tag(line)
        return
      end
    end
  end

  # Parse the object type from the file name
  def parse_object_type_from_file_name(file)
    file[0, file.index('_on')]
  end

  # Change private dns line
  def replace_ip_with_regex_in_line(line)

    first = line.slice(0, line.index('{') + 1)
    last = line.slice(line.index('.'), line.length)
               .gsub(/\./, '\.')
               .tr("'", '/')
    first + ' should match /ip-[\d]{1,3}-[\d]{1,3}-[\d]{1,3}-[\d]{1,3}' + last
  end

  # Change private ip line
  def replace_private_ip_with_regex(line)
    line = line.slice(0, line.index('{') + 1)
    line + ' should match /[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}/ }' + "\n"
  end

  # Set the class tag var
  def set_environment_tag(line)
    case line
    when MatchesInt
      @tag = ', int: true'
    when MatchesDevint
      @tag = ', devint: true'
    when MatchesFt
      @tag = ', ft: true'
    when MatchesInfradev
      @tag = ', infradev: true'
    when MatchesPpd
      @tag = ', ppd: true'
    when MatchesStg
      @tag = ', stg: true'
    else
      @tag = ''
    end
  end

  # Set the output file for a generator and create sub dir if not set
  def setup_generator_output(type, account, file)
    directory = @target_root_directory + "#{type}_tests_#{account}"
    FileUtils.mkdir_p directory unless Dir.exists?(directory)
    File.absolute_path(directory) + File::SEPARATOR + file
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def transform_line(line)
    line = '  ' + line
    case line
    when MatchesAclOwner
      line = ''
    when MatchesContextLine
      line.lstrip!
      line = insert_environment_tag(line)
    when MatchesDescribeLine
      line = insert_dynamic_resource(line)
      @described = true
    when MatchesHaveEbs
      return ''
    # Uncomment to ignore :image_id and :instance_id
    # when MatchesImageId
    #   return ''
    # when MatchesInstanceId
    #   return ''
    when MatchesNetworkInterfaceLine
      return ''
    when MatchesPrivateDnsNameLine
      line = replace_ip_with_regex_in_line(line)
    when MatchesPrivateIpAddressLine
      line = replace_private_ip_with_regex(line)
    when MatchesRequireLine
      line = line.strip! + "\n"
    end
    line
  end
end