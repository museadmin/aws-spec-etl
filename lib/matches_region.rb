
# Match region
class MatchesRegion
  def self.===(item)
    item.include?('region')
  end
end