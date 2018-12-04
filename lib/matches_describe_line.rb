
# Match a describe statement
class MatchesDescribeLine
  def self.===(item)
    item.include?('describe')
  end
end