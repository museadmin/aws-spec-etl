# frozen_string_literal: true

# Traverse a directory tree looking for files with a specific extension
class FileSieve
  attr_reader :found_files

  def initialize(directory, extension)
    @found_files = []
    @extension = extension
    @search_directory = directory
    sieve(directory)
  end

  # Recursively search the directory tree for files with @extension
  def sieve(directory)
    de_dot(Dir.entries(directory)).each { |file|
      search = File.absolute_path(directory + File::SEPARATOR + file)
      if File.directory?(search)
        sieve(search)
      elsif file.match?(@extension)
        @found_files.push(search)
      end
    }
  end

  # Clean away . and .. from the directory list
  def de_dot(list)
    list.delete('.')
    list.delete('..')
    list
  end

end
