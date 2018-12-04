
# Match -int-
class MatchesInt
  def self.===(item)
    item.include?('-int.int') || item.include?('-INT-')
  end
end