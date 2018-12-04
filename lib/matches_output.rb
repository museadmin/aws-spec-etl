
# Match output
class MatchesOutput
  def self.===(item)
    item.include?('output')
  end
end